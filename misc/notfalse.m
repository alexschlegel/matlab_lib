function b = notfalse(x)
% notfalse
% 
% Description:	not false! use this when the expression may be empty, a struct,
%				etc.
% 
% Syntax:	b = notfalse(x)
% 
% Updated: 2014-01-22
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
try
	b	= ~isempty(x) && all(x | false);
catch
	b	= ~isequal(x, struct);
end
