function strPathMAT = NIfTIPathMAT(strPathData)
% NIfTIPathMAT
% 
% Description:	get the path to a .mat file associated with a NIfTI file (if the
%				file was converted with PARREC2NIfTI)
% 
% Syntax:	strPathMAT = NIfTIPathMAT(strPathData)
% 
% Updated: 2013-10-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%first just check for a direct equivalent
	strPathMAT	= PathAddSuffix(strPathData,'','mat','favor','nii.gz');
	
	if FileExists(strPathMAT)
		return;
	end
%now check for a related .mat file
	[strDir,strFilePre,strExt]	= PathSplit(strPathData,'favor','nii.gz');
	
	strPrefix	= GetFieldPath(regexp(strFilePre,'(?<prefix>data[^-]*)','names'),'prefix');
	
	strPathMAT	= PathUnsplit(strDir,strPrefix,'mat');
	
	if FileExists(strPathMAT)
		return;
	end
%nope
	strPathMAT	= [];
