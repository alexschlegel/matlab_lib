function f = FSLReadFTest(strPath)
% FSLReadFTest
% 
% Description:	read an FSL-formatted f-test file
% 
% Syntax:	f = FSLReadFTest(strPath)
% 
% Updated: 2012-03-31
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strFile	= fget(strPath);
s		= regexp(strFile,'/Matrix[\r\n]+(?<mat>.+)$','names');
f		= str2array(s.mat);
