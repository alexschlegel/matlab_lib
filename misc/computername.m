function strName = computername
% computername
% 
% Description:	return the computer name
% 
% Syntax:	strName = computername
% 
% Updated: 2012-04-29
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[err,strName]	= system('hostname');
strName			= StringTrim(strName);
