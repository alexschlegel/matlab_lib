function t = p2t(p,v,varargin)
% p2t
% 
% Description:	calculate t-statistics for the given p-values
% 
% Syntax:	t = p2t(p,v,[bTwoTail]=false)
% 
% In:
% 	p			- the p-values
%	v			- degrees of freedom for each t value
%	[bTwoTail]	- true to if p is two-tailed
% 
% Out:
% 	t	- the associated (positive) t-statistics
% 
% Updated: 2014-03-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bTwoTail	= ParseArgs(varargin,false);

if bTwoTail
	p	= p/2;
end

t	= tinv(1-p,v);
