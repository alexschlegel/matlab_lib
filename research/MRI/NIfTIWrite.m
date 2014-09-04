function NIfTIWrite(nii,strPathNIfTI)
% NIfTIWrite
% 
% Description:	write a NIfTI file.  requires spm8's nifti class or load_nii,
%				depending on the method used by NIfTIRead
% 
% Syntax:	NIfTIWrite(nii,strPathNIfTI)
% 
% In:
%	nii				- the NIfTI data read with NIfTIRead
% 	strPathNIfTI	- path to the output NIfTI file
% 
% Updated: 2011-03-01
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strPathNIfTI	= PathRel2Abs(strPathNIfTI,pwd);

switch lower(PathGetExt(strPathNIfTI,'favor','nii.gz'))
	case 'nii'
		%delete the old file
			if exist(strPathNIfTI,'file')
				delete(strPathNIfTI);
			end
		
		switch GetNIfTIReadMethod(nii)
			case 'spm'
				%create a new file array
					dat			= file_array;
				%transfer the file array info
					cField	= setdiff(fieldnames(nii.orig.dat),{'fname','dim'});
					nField	= numel(cField);
					for kF=1:nField
						dat.(cField{kF})	= nii.orig.dat.(cField{kF});
					end
				%update the changed info
					dat.fname	= strPathNIfTI;
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
				save_nii(nii,strPathNIfTI);
		end
	case 'nii.gz'
		%save the data, gzip it, then delete the uncompressed file
			%write the ungzipped files
				strPathTemp		=  GetTempFile('ext','nii');
				strPathTempGZ	= PathAddSuffix(strPathTemp,'','nii.gz');
			
				NIfTIWrite(nii,strPathTemp);
			%gzip it
				gzip(strPathTemp);
			
				if FileExists(strPathTemp)
					delete(strPathTemp);
				end
			%move to the final destination
				movefile(strPathTempGZ,strPathNIfTI);
	otherwise
		error('Unsupported file format.');
end

%------------------------------------------------------------------------------%
function strMethod = GetNIfTIReadMethod(nii)
	if isfield(nii,'data')
		strMethod	= 'spm';
	elseif isfield(nii,'img')
		strMethod	= 'load_nii';
	else
		error('Unknown NIfTI structure.  Only NIfTI data read with NIfTIRead can be saved using this function.');
	end
%------------------------------------------------------------------------------%
