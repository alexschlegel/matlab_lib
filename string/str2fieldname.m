function str = str2fieldname(str)
% str2fieldname
% 
% Description:	convert a string to a valid fieldname
% 
% Syntax:	fn = str2fieldname(str)
% 
% Updated:	2012-11-13
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

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
