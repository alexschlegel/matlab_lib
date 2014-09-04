function x = left(x,n)
% left
% 
% Description:	return the leftmost n elements of x
% 
% Syntax:	x = left(x,n)
% 
% Updated:	2009-08-25
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
nX	= numel(x);

if nX>n
	x	= x(1:n);
end
