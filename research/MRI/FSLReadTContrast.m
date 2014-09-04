function t = FSLReadTContrast(strPath)
% FSLReadTContrast
% 
% Description:	read an FSL-formatted t-contrast file
% 
% Syntax:	t = FSLReadTContrast(strPath)
% 
% Updated: 2012-03-31
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strFile	= fget(strPath);
s		= regexp(strFile,'/Matrix[\r\n]+(?<mat>.+)$','names');
t		= str2array(s.mat);
