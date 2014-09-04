function x = right(x,n)
% right
% 
% Description:	return the rightmost n elements of x
% 
% Syntax:	x = right(x,n)
% 
% Updated:	2009-08-25
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
nX	= numel(x);

if nX>n
	x	= x(nX-n+1:end);
end
