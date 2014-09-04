function strDirFEAT = FSLDirFEAT(strPathData)
% FSLDirFEAT
% 
% Description:	get the feat directory associated with the given functional
%				data file
% 
% Syntax:	strDirFEAT = FSLDirFEAT(strPathData)
% 
% Updated: 2013-10-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strSuffix	= GetFieldPath(regexp(PathGetFilePre(strPathData,'favor','nii.gz'),'data(?<suffix>[^-]*)','names'),'suffix');
strDirFEAT	= DirAppend(PathGetDir(strPathData),['feat' strSuffix]);
