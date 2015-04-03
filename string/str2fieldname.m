function str = str2fieldname(str)
% str2fieldname
% 
% Description:	convert a string to a valid fieldname
% 
% Syntax:	str = str2fieldname(str)
% 
% Updated: 2015-03-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%replace non-good characters with underscores
	str	= regexprep(str,'[^A-Za-z0-9]+','_');
%make sure the string starts with a letter
	str	= regexprep(str,'^[^A-Za-z]+','');
%trim underscores from the end
	str	= regexprep(str,'[_]+$','');
%make sure we have something
	if isempty(str)
		str	= 'X';
	end
