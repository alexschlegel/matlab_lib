function x = unsort(x,kSort)
% unsort
% 
% Description:	unsort a previously sorted array
% 
% Syntax:	x = unsort(x,kSort)
% 
% In:
% 	x		- a sorted array
%	kSort	- the sorting index array
% 
% Out:
% 	x	- x unsorted
% 
% Updated:	2009-08-10
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the inverse sorting index
	[kSort,kInverse]	= sort(kSort);
%unsort
	x	= x(kInverse);
