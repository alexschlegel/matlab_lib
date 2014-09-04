function str = StringReduceWhitespace(str)
% StringReduceWhitespace
% 
% Description:	eliminate multiple consecutive whitespace characters in a string
% 
% Syntax:	str = StringReduceWhitespace(str)
% 
% In:
% 	str	- a string
% 
% Out:
% 	str	- the string with whitespace reduced
% 
% Updated: 2010-02-25
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
str	= StringReduceCharacter(str,'\s');
