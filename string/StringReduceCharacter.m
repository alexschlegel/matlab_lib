function str = StringReduceCharacter(str,chr)
% StringReduceCharacter
% 
% Description:	eliminate multiple consecutive characters in a string
% 
% Syntax:	str = StringReduceCharacter(str,chr)
% 
% In:
% 	str	- a string
%	chr	- the character to reduce.  can include regexp code (e.g. \s)
% 
% Out:
% 	str	- the string with the character reduced
% 
% Updated: 2010-02-25
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
str	= regexprep(str,[chr '+(' chr ')'],'$1');
