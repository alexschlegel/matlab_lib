function y = squarify(x)
% squarify
% 
% Description:	reshape an array to be as square as possible
% 
% Syntax: y = squarify(x)
% 
% In:
%	x		- an array
% 
% Out:
%	y	- a reshaped version of x in which the dimensions are as uniformly sized
%		  as possible
% 
% Updated:	2016-01-27
% Copyright 2016 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
n	= numel(x);

%get the divisors of n
	d	= divisors(n);

%find the divisor whose complement is most similar to itself
	c	= n./d;
	
	dff	= abs(d-c);
	k	= find(dff==min(dff),1);

%reshape
	s1	= min(d(k),c(k));
	s2	= max(d(k),c(k));
	y	= reshape(x,s1,s2);
