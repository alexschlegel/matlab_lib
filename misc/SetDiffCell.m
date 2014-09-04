function [c,k] = SetDiffCell(a,b)
% SetDiffCell
% 
% Description:	set diff implemented for arbitrary (not just string) cells
% 
% Syntax:	[c,k] = SetDiffCell(a,b)
% 
% In:
% 	a	- a cell
%	b	- another cell
% 
% Out:
% 	c	- a cell of the elements of a that aren't in b
%	k	- the indices of a in c (so that c = a(k))
% 
% Updated:	2009-01-13
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

tf	= IsMemberCell(a,b);

k	= find(~tf);
c	= a(k);

	