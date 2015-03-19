function x = bitmult(a,b)
% bitmult
% 
% Description:	multiply two numbers represented as bit arrays
% 
% Syntax:	x = bitmult(a,b)
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nA	= numel(a);
nB	= numel(b);

if nB<nA
	c	= reshape(b,1,[]);
	d	= a;
	n	= nA;
else
	c	= reshape(a,1,[]);
	d	= b;
	n	= nB;
end

x	= [];

for k=1:n
	if d(k)
		x	= bitadd(x,[false(1,k-1) c]);
	end
end
