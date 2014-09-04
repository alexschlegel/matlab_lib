function c = choose(n,k)
% choose
% 
% Description:	n choose k
% 
% Syntax:	c = choose(n,k)
%
% In:
%	n	- a number
%	k	- a number s.t. 0<=k<=n
% 
% Out:
%	c	- the number of ways to choose k things from a set of n things
%
% Updated:	2012-01-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
c	= round(factorial(n) ./ (factorial(k) .* factorial(n-k)));
