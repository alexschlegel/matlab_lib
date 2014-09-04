function [k,vNear] = FindNearest(x,v)
% FindNearest
% 
% Description:	find the closest value to v in x
% 
% Syntax:	[k,vNear] = FindNearest(x,v)
% 
% In:
% 	x	- an array
%	v	- the value to search for
% 
% Out:
% 	k		- the position of the nearest value to v in x
%	vNear	- the nearest value
% 
% Updated:	2008-11-09
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the difference between the x values and v
	vDiff	= abs(x-v);
	k		= find(vDiff(:)==min(vDiff(:)),1,'first');
	vNear	= x(k);
