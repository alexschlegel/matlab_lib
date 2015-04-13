function strPathMAT = PathMAT(strPathData)
% NIfTI.PathMAT
% 
% Description:	get the path to a .mat file associated with a NIfTI file (if the
%				file was converted with PARREC2NIfTI)
% 
% Syntax:	strPathMAT = NIfTI.PathMAT(strPathData)
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
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
