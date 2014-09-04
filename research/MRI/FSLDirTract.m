function strDirTract = FSLDirTract(strDirDTI,strNameTract)
% FSLDirTract
% 
% Description:	get the path to a probtrackx output directory
% 
% Syntax:	strDirTract = FSLDirTract(strDirDTI,strNameTract)
% 
% In:
% 	strDirDTI		- the DTI data directory path
%	strNameTract	- the name of the tract (i.e. the name of the tract folder in
%					  <strDirDTI>.probtrackX/)
% 
% Out:
% 	strDirTract	- the path to the probtrackx output directory
% 
% Updated: 2011-03-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strDirTract	= DirAppend(FSLDirPTX(strDirDTI),strNameTract);
