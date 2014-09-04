function y = todouble(x)
% todouble
% 
% Description:	convert a variable to a double for display.  strings keep their
%				represented value.
% 
% Syntax:	y = todouble(x,<options>)
% 
% In:
% 	x	- a variable
% 
% Out:
% 	y	- the variable as a double
% 
% Updated: 2014-02-20
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

if isnumeric(x) || islogical(x)
	y	= double(x);
elseif ischar(x)
	y	= str2array(x);
else
	y	= varsize(x);
end
