function Write(nii,strPathNII,varargin)
% NIfTI.Write
% 
% Description:	write a NIfTI file to disk
% 
% Syntax:	NIfTI.Write(nii,strPathNII,<options>)
% 
% In:
%	nii			- a NIfTI data struct read with NIfTI.Read
% 	strPathNII	- path to the output NIfTI file
%	<options>:
%		datatype:	('auto') the output data type. one of the following:
%						auto:		choose the best data type. this will keep
%									the .data field's data type unless it is
%									logical, in which case the data are saved as
%									uint8 (FSL can't handle ubit1 data type)
%						keep:		keep the data type of the .data field
%						ubit1:		logical
%						<other>:	cast the data into the specified type before
%									saving
%		version:	(<same>) the NIfTI version to save. only applies if nii was
%					read using the nii_tool method
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input
	opt	= ParseArgs(varargin,...
			'datatype'	, 'auto'	, ...
			'version'	, []		  ...
			);
	
	strExt	= PathGetExt(strPathNII,'favor','nii.gz');
	strExt	= CheckInput(strExt,'extension',{'nii','nii.gz'});
	
	bZip	= strcmp(strExt,'nii.gz');
	if bZip
		strPathZip	= strPathNII;
		strPathNII	= GetTempFile('ext','nii');
	end
	
	assert(isfield(nii,'method'),'NIfTI struct must have been read with NIfTI.Read');

%convert to the specified output data type
	if strcmp(opt.datatype,'ubit1')
		opt.datatype	= 'logical';
	end
	
	switch lower(opt.datatype)
		case 'auto'
			switch class(nii.data)
				case 'file_array'
					if startswith(lower(nii.data.dtype),'binary')
						nii.data	= reshape(uint8(nii.data(:)),size(nii.data));
					end
				case 'logical'
					nii.data	= uint8(nii.data);
			end
		case 'keep'
		otherwise
			nii.data	= reshape(cast(nii.data(:),opt.datatype),size(nii.data));
	end

%save the nii file
	switch nii.method
		case 'nii_tool'
			nii.img	= reshape(nii.data(:),size(nii.data));
			nii		= rmfield(nii,'data');
			
			if ~isempty(opt.version)
				nii.hdr.version	= opt.version;
			end
			
			nii_tool('save',nii,strPathNII);
		case 'spm'
				%create a new file array
					dat		= file_array;
				%transfer the file array info
					cField	= setdiff(fieldnames(nii.orig.dat),{'fname','dim'});
					nField	= numel(cField);
					for kF=1:nField
						dat.(cField{kF})	= nii.orig.dat.(cField{kF});
					end
				%update the changed info
					dat.fname	= strPathNII;
					dat.dim		= size(nii.data);
				
				%create a new nifti
					niiSPM		= nifti;
					niiSPM.dat	= dat;
					
					cField	= setdiff(fieldnames(nii.orig),{'dat'});
					nField	= numel(cField);
					for kF=1:nField
						niiSPM.(cField{kF})	= nii.orig.(cField{kF});
					end
				
				%write the hdr info
					create(niiSPM);
				%write the data
					dat(:)	= nii.data(:);
		case 'load_nii'
			nii.img	= nii.data;
			nii		= rmfield(nii,'data');
			
			save_nii(nii,strPathNII);
		otherwise
			error('"%s" is an unrecognized load method',nii.method);
	end

%gzip the output
	if bZip
		strPathNIIGZ	= PathAddSuffix(strPathNII,'','nii.gz');
		
		%gzip it
			gzip(strPathNII);
		%delete the original
			if FileExists(strPathNII)
				delete(strPathNII);
			end
		%move to the specified location
			movefile(strPathNIIGZ,strPathZip);
	end
