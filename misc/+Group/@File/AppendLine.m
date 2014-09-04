function b = AppendLine(f,strLine,strName)
% Group.File.AppendLine
% 
% Description:	append a line to a named text file
% 
% Syntax:	b = f.AppendLine(strLine,strName)
% 
% In:
%	str		- the line to append
% 	strName	- the file name (previously assigned using f.Set)
% 
% Out:
%	b	- true if the file was successfully appended
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= f.Append([10 strLine],strName);
