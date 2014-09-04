function b = cellequal(c,v)
% cellequal
% 
% Description:	returns a logical array the same size as c with 1 where the
%				equivalent element of c is equal to v and 0 otherwise
% 
% Syntax:	b = cellequal(c,v)
% 
% Updated:	2008-06-20
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

b	= logical(zeros(size(c)));
n	= numel(b);

for k=1:n
	if isequal(c{k},v)
		b(k)	= 1;
	end
end
