function r = randBetween(r1,r2,varargin)
% randBetween
% 
% Description:	choose random numbers between two values
% 
% Syntax:	r = randBetween(r1,r2,<size>)
% 
% In:
% 	r1		- lower bound
%	r2		- upper bound
%	<size>	- the size of the return matrix (same as for rand)
% 
% Out:
% 	r	- a matrix of random numbers between r1 and r2
% 
% Updated:	2008-11-05
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

r	= rand(varargin{:});
r	= r1 + r.*(r2-r1);
