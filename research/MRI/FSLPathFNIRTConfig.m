function strConfig = FSLPathFNIRTConfig(strConfig)
% FSLPathFNIRTConfig
% 
% Description:	find the path to the specified FNIRT configuration file
% 
% Syntax:	strConfig = FSLPathFNIRTConfig(strConfig)
% 
% In:
% 	strConfig	- the name/path of the configuration file, or the path to a
%				  NIfTI file from which to base the configuration (see code for
%				  supported NIfTI files)
% 
% Out:
% 	strConfig	- the path to the configuration file
% 
% Updated: 2011-03-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isempty(strConfig)
	return;
end

[strDirConfig,strFilePreConfig,strExtConfig]	= PathSplit(strConfig,'favor','nii.gz');

switch strExtConfig
	case {'nii','nii.gz'}
		if regexp(strFilePreConfig,'MNI152_T1_1mm')
			strConfig	= FSLPathFNIRTConfig('MNI152_T1_1mm');
		elseif regexp(strFilePreConfig,'MNI152_T1_2mm')
			strConfig	= FSLPathFNIRTConfig('T1_2_MNI152_2mm');
		elseif regexp(strFilePreConfig,'FMRIB58_FA_1mm')
			strConfig	= FSLPathFNIRTConfig('FA_2_FMRIB58_1mm');
		elseif regexp(strFilePreConfig,'FMRIB58_FA_2mm')
			strConfig	= FSLPathFNIRTConfig('FA_2_FMRIB58_2mm');
		else
			strConfig	= '';
		end
	otherwise
		strDirMFile	= PathGetDir(mfilename('fullpath'));
		
		if isempty(strDirConfig)
			strNameConfig	= strConfig;
			
			cExt	= {'','cnf'};
			nExt	= numel(cExt);
			
			cDir	= 	{
							pwd
							DirAppend(GetDirFSL,'etc','flirtsch')
							DirAppend(strDirMFile,'fsl','etc','flirtsch')
						};
			nDir	= numel(cDir);
			
			for kE=1:nExt
				for kD=1:nDir
					strConfig	= PathUnsplit(cDir{kD},strNameConfig,cExt{kE});
					if FileExists(strConfig)
						return;
					end
				end
			end
			
			strConfig	= strNameConfig;
		end
end
