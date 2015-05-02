function hdr = ReadHeader(strPathNII)
% NIfTI.Read
% 
% Description:	read a NIfTI file header
% 
% Syntax:	hdr = NIfTI.ReadHeader(strPathNII)
% 
% Updated: 2015-04-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent hDef fRead;

%NIfTI header definitions and file functions
	if isempty(hDef)
		hField1	=	{
						'int32'		1	'sizeof_hdr'		%size of header (348)
						'char'		10	'data_type'			%unused
						'char'		18	'db_name'			%unused
						'int32'		1	'extents'			%unused
						'int16'		1	'session_error'		%unused
						'char'		1	'regular'			%unused
						'char'		1	'dim_info'			%mri slice ordering
						'int16'		8	'dim'				%data array dimensions
						'single'	1	'intent_p1'			%1st intent parameter
						'single'	1	'intent_p2'			%2nd intent parameter
						'single'	1	'intent_p3'			%3rd intent parameter
						'int16'		1	'intent_code'		%NIFTI_INTENT_* code
						'int16'		1	'datatype'			%defines data type
						'int16'		1	'bitpix'			%number bits/voxel
						'int16'		1	'slice_start'		%first slice index
						'single'	8	'pixdim'			%grid spacings
						'single'	1	'vox_offset'		%offset into .nii file
						'single'	1	'scl_slope'			%data scaling: slope
						'single'	1	'scl_inter'			%data scaling: offset
						'int16'		1	'slice_end'			%last slice index
						'char'		1	'slice_code'		%slice timing order
						'char'		1	'xyzt_units'		%units of pixdim[1..4]
						'single'	1	'cal_max'			%max display intensity
						'single'	1	'cal_min'			%min display intensity
						'single'	1	'slice_duration'	%time for 1 slice
						'single'	1	'toffset'			%time axis shift
						'int32'		1	'glmax'				%unused
						'int32'		1	'glmin'				%unused
						'char'		80	'descrip'			%file description
						'char'		24	'aux_file'			%auxiliary filename
						'int16'		1	'qform_code'		%NIFTI_XFORM_* code
						'int16'		1	'sform_code'		%NIFTI_XFORM_* code
						'single'	1	'quatern_b'			%quaternion b param
						'single'	1	'quatern_c'			%quaternion c param
						'single'	1	'quatern_d'			%quaternion d param
						'single'	1	'qoffset_x'			%quaternion x shift
						'single'	1	'qoffset_y'			%quaternion y shift
						'single'	1	'qoffset_z'			%quaternion z shift
						'single'	4	'srow_x'			%1st row affine transform
						'single'	4	'srow_y'			%2nd row affine transform
						'single'	4	'srow_z'			%3rd row affine transform
						'char'		16	'intent_name'		%name or meaning of data
						'char'		4	'magic'				%must be "ni1\0" (for .img/.hdr data) or "n+1\0" (for .nii data)
					};
		
		hField2	=	{
						'int32'		1	'sizeof_hdr'		%(540)
						'char'		8	'magic'				%must be a valid signature
						'int16'		1	'datatype'			%
						'int16'		1	'bitpix'			%
						'int64'		8	'dim'				%
						'double'	1	'intent_p1'			%
						'double'	1	'intent_p2'			%
						'double'	1	'intent_p3'			%
						'double'	8	'pixdim'			%
						'int64'		1	'vox_offset'		%
						'double'	1	'scl_slope'			%
						'double'	1	'scl_inter'			%
						'double'	1	'cal_max'			%
						'double'	1	'cal_min'			%
						'double'	1	'slice_duration'	%
						'double'	1	'toffset'			%
						'int64'		1	'slice_start'		%
						'int64'		1	'slice_end'			%
						'char'		80	'descrip'			%
						'char'		24	'aux_file'			%
						'int32'		1	'qform_code'		%
						'int32'		1	'sform_code'		%
						'double'	1	'quatern_b'			%
						'double'	1	'quatern_c'			%
						'double'	1	'quatern_d'			%
						'double'	1	'qoffset_x'			%
						'double'	1	'qoffset_y'			%
						'double'	1	'qoffset_z'			%
						'double'	4	'srow_x'			%
						'double'	4	'srow_y'			%
						'double'	4	'srow_z'			%
						'int32'		1	'slice_code'		%
						'int32'		1	'xyzt_units'		%
						'int32'		1	'intent_code'		%
						'char'		16	'intent_name'		%
						'char'		1	'dim_info'			%
						'char'		15	'unused_str'		%unused, filled with \0
					};
		
		hDef.field	= {hField1; hField2};
		hDef.size	= [348; 540];
		
		fRead.nii		= struct(...
							'open'	, @niiOpen	, ...
							'read'	, @niiRead	, ...
							'close'	, @niiClose	  ...
							);
		fRead.nii_gz	= struct(...
							'open'	, @niigzOpen	, ...
							'read'	, @niigzRead	, ...
							'close'	, @niigzClose	  ...
							);
	end

%read the header
	hdr	= struct;
	
	%get the file type
		strExt	= str2fieldname(lower(PathGetExt(strPathNII,'favor','nii.gz')));
		
		assert(isfield(fRead,strExt),'unsupported file type');
		
		f	= fRead.(strExt);
	
	%open the NIfTI file
		nii	= f.open(strPathNII);
	
	%read the size of the header to figure out the file version
		hdr.sizeof_hdr	= f.read(nii,'int32',1);
		hdr.version		= find(hdr.sizeof_hdr==hDef.size,1);
		
		assert(~isempty(hdr.version),'%d byte headers are unsupported',hdr.sizeof_hdr);
		
		cField	= hDef.field{hdr.version};
		
		%already read the first field
			cField	= cField(2:end,:);
	
	%read each of the fields
		nField	= size(cField,1);
		for kF=1:nField
			[dType,dLen,strField]	= deal(cField{kF,:});
			
			hdr.(strField)	= f.read(nii,dType,dLen);
		end
	
	%close the NIfTI file
		f.close(nii);

%add some derived properties
	%transform matrix (stolen from SPM's code)
		if hdr.sform_code>0
		%derived from sform
			hdr.mat			= [hdr.srow_x; hdr.srow_y; hdr.srow_z; 0 0 0 1];
			hdr.mat			= hdr.mat * [eye(4,3) [-1; -1; -1; 1]];
		elseif isfield(hdr,'magic') && hdr.qform_code>0
		%derived from qform
			%convert quaternion to rotation
				R = q2m([hdr.quatern_b hdr.quatern_c hdr.quatern_d]);
		
			%translation
				T	= [eye(4,3) [hdr.qoffset_x; hdr.qoffset_y; hdr.qoffset_z; 1]];
		
			%scaling
				n		= min(hdr.dim(1),3);
				Z		= [hdr.pixdim(2:(n+1)) ones(1,4-n)];
				Z(Z<0)	= 1;
				
				if hdr.pixdim(1)<0
					Z(3)	= -Z(3);
				end
				
				Z	= diag(Z);
		
			hdr.mat	= T*R*Z * [eye(4,3) [-1 -1 -1 1]'];
		else
			n	= min(hdr.dim(1),3);
			vox	= [hdr.pixdim(2:(n+1)) ones(1,3-n)];
			
			origin	= (hdr.dim(2:4)+1)/2;
			off		= -vox.*origin;
			hdr.mat	=	[
							vox(1)	0		0		off(1)
							0		vox(2)	0		off(2)
							0		0		vox(3)	off(3)
							0		0		0		1
						];
		end

%------------------------------------------------------------------------------%
function nii = niiOpen(strPathNII)
	nii	= fopen(strPathNII,'r');
end
%------------------------------------------------------------------------------%
function x = niiRead(nii,dType,dLen)
	x	= reshape(fread(nii,dLen,dType),1,dLen);
	
	if strcmp(dType,'char')
		x	= fixChar(x);
	end
end
%------------------------------------------------------------------------------%
function niiClose(nii)
	fclose(nii);
end
%------------------------------------------------------------------------------%
function nii = niigzOpen(strPathNII)
	file		= java.io.File(strPathNII);
	fileStream	= java.io.FileInputStream(file);
	gzStream	= java.util.zip.GZIPInputStream(fileStream);
	nii			= struct('file',fileStream,'gz',gzStream);
end
%------------------------------------------------------------------------------%
function x = niigzRead(nii,dType,dLen)
	persistent dByte;
	
	if isempty(dByte)
		dByte	= struct(...
					'char'		, 1	, ...
					'double'	, 8	, ...
					'single'	, 4	, ...
					'int16'		, 2	, ...
					'int32'		, 4	, ...
					'int64'		, 8	  ...
					);
	end
	
	%read the bytes
		nByte	= dByte.(dType);
		xb		= zeros(nByte,dLen);
		n		= nByte*dLen;
		
		for k=1:n
			xb(k)	= nii.gz.read();
		end
	
	%convert to the output data type
		if strcmp(dType,'char')
			x	= fixChar(xb);
		else
			x	= zeros(1,dLen);
			
			for k=1:dLen
				x(k)	= typecast(uint8(xb(:,k)),dType);
			end
		end
end
%------------------------------------------------------------------------------%
function niigzClose(nii)
	nii.gz.close;
	nii.file.close;
end
%------------------------------------------------------------------------------%
function x = fixChar(x)
	x	= char(x);
	
	kZero	= find(x==0,1,'first');
	if isempty(kZero)
		kZero	= numel(x)+1;
	end
	
	x	= x(1:kZero-1);

	if isempty(x)
		x	= '';
	end
end
%------------------------------------------------------------------------------%

end
