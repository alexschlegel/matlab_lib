function b = nottrue(x)
% nottrue
% 
% Description:	not true! use this when the expression may be empty, a struct,
%				etc.
% 
% Syntax:	b = nottrue(x)
% 
% Updated: 2014-01-22
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
try
	b	= isempty(x) || any(~x & true);
catch
	b	= true;
end
