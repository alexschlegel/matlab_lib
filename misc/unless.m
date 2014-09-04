function y = unless(x,z,varargin)
% setunless
% 
% Description:	return x unless it is a specific value, in which case return z
% 
% Syntax:	y = unless(x,z,[v]=[])
% 
% In:
% 	x	- the value to return...unless
%	z	- the value to return if x fits the test condition
%	[v]	- if x==v (including NaN), then return z.  if v is empty, then z will be
%		  returned if x is any empty value
% 
% Updated: 2014-02-14
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
v	= ParseArgs(varargin,[]);

if isempty(v)
	b	= isempty(x);
else
	b	= isequalwithequalnans(x,v);
end

y	= conditional(b,z,x);
