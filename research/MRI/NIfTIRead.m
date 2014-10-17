function nii = NIfTIRead(strPathNIfTI,varargin)
% NIfTIRead
% 
% Description:	read a NIfTI file.  requires spm8's nifti class
% 
% Syntax:	nii = NIfTIRead(strPathNIfTI,<options>)
% 
% In:
% 	strPathNIfTI	- path to the NIfTI file
%	<options>:
%		method:		('spm') the method to use to load the NIfTI data.  one of
%					the following:
%						'spm':		use SPM's nifti function
%						'load_nii':	use Jimmy Shen's load_nii function
%					note that the NIfTI struct is different depending on which
%					method is used.
%		readdata:	(true) true to read the data into a double array from the
%					SPM file_array.  only applies if <method>=='spm'
% 
% Out:
% 	nii			- the NIfTI struct
% 
% Updated: 2012-01-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'method'	, 'spm'	, ...
		'readdata'	, true	  ...
		);

strPathNIfTI	= PathRel2Abs(strPathNIfTI,pwd);
strPathHDR		= PathAddSuffix(strPathNIfTI,'','mat','favor','nii.gz');

switch lower(PathGetExt(strPathNIfTI,'favor','nii.gz'))
	case 'nii'
		switch lower(opt.method)
			case 'spm'
				nii.orig	= nifti(strPathNIfTI);
				
				if opt.readdata
					nii.data	= reshape(nii.orig.dat(:),nii.orig.dat.dim);
				else
					nii.data	= nii.orig.dat;
				end
				
				nii.mat		= nii.orig.mat;
			case 'load_nii'
				nii	= load_nii(strPathNIfTI);
			otherwise
				error(['"' tostring(opt.method) '" is an invalid method for loading NIfTI data.']);
		end
	case 'nii.gz'
		if ~opt.readdata
			error('"readdata" option must be true for gzipped NIfTI files.');
		end
		
		%uncompress, load, then delete the uncompressed file
			strDirTemp	= GetTempDir;
			strPathTemp	= char(gunzip(strPathNIfTI,strDirTemp));
			nii			= NIfTIRead(strPathTemp,varargin{:});
			
			rmdir(strDirTemp,'s');
	otherwise
		error('Unsupported file format.');
end

if FileExists(strPathHDR)
	try
		nii.mathdr	= load(strPathHDR);
	catch me
	end
end
