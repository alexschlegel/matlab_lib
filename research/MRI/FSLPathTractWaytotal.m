function strPathWaytotal = FSLPathTractWaytotal(strDirDTI,strNameTract)
% FSLPathWaytotal
% 
% Description:	get the path to a probtrackx tract waytotal file
% 
% Syntax:	strPathWaytotal = FSLPathTractWaytotal(strDirDTI,strNameTract)
% 
% In:
% 	strDirDTI		- the DTI data directory path
%	strNameTract	- the name of the tract (i.e. the name of the tract folder in
%					  <strDirDTI>.probtrackX/)
% 
% Out:
% 	strPathWaytotal	- the path to the tract waytotal file
% 
% Updated: 2011-03-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strPathWaytotal	= PathUnsplit(FSLDirTract(strDirDTI,strNameTract),'waytotal');
