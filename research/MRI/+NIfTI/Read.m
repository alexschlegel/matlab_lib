function nii = Read(strPathNII,varargin)
% NIfTI.Read
% 
% Description:	read a NIfTI file
% 
% Syntax:	nii = NIfTI.Read(strPathNII,<options>)
% 
% In:
% 	strPathNII	- path to the NIfTI file
%	<options>:
%		method:	('nii_tool') the method to use to load the NIfTI data.  one of
%				the following:
%					'nii_tool':	use the nii_tool function supplied with
%								dicm2nii
%					'spm':		use SPM's nifti function
%					'load_nii':	use Jimmy Shen's load_nii function
%				note that the NIfTI struct is different depending on which
%				method is used.
%		load:	(true) true to read the data into an array, false to use an SPM
%				file_array (only if the file is not gzipped)
%		return:	('struct') what to return. one of:
%					struct:	the full NIfTI struct
%					data:	just the data array
% 
% Out:
% 	nii	- the NIfTI struct
% 
% Updated: 2015-12-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'method'	, 'nii_tool'	, ...
			'load'		, true			, ...
			'return'	, 'struct'		  ...
			);
	
	opt.method	= CheckInput(opt.method,'method',{'nii_tool','spm','load_nii'});
	opt.return	= CheckInput(opt.return,'return value',{'struct','data'});
	
	strExt	= PathGetExt(strPathNII,'favor','nii.gz');
	strExt	= CheckInput(strExt,'extension',{'nii','nii.gz'});

%for spm and load_nii methods, we have to ungzip and load if we have a gzipped
%NIfTI file
	if ismember(opt.method,{'spm','load_nii'}) && strcmp(strExt,'nii.gz')
		opt.load	= true;
		
		strDirTemp	= GetTempDir;
		strPathTemp	= char(gunzip(strPathNII,strDirTemp));
		
		nii	= NIfTI.Read(strPathTemp,varargin{:});
		
		rmdir(strDirTemp,'s');
		
		return;
	end

%load the data with the specified method
	switch opt.method
		case 'nii_tool'
			hdr	= NIfTI.ReadHeader(strPathNII);
			
			if opt.load || strcmp(strExt,'nii.gz')
				nii	= nii_tool('load',strPathNII);
				
				nii.hdr		= hdr;
				nii.data	= nii.img;
				nii			= rmfield(nii,'img');
			else
				sz		= hdr.dim(1 + (1:hdr.dim(1)));
				dType	= hdr.datatype;
				offset	= hdr.vox_offset;
				
				nii.data	= file_array(strPathNII,sz,dType,offset);
			end
		case 'spm'
			nii.orig	= nifti(strPathNII);
			
			if opt.load
				nii.data	= reshape(nii.orig.dat(:),nii.orig.dat.dim);
			else
				nii.data	= nii.orig.dat;
			end
			
			nii.hdr	= nii.orig.hdr;
			nii.mat	= nii.orig.mat;
		case 'load_nii'
			nii	= load_nii(strPathNII);
			
			nii.data	= nii.img;
			nii			= rmfield(nii,'img');
	end

%keep track of which method we used to load the data
	nii.method	= opt.method;

%return the specified data
	switch opt.return
		case 'struct'
		case 'data'
			nii	= nii.data;
	end
