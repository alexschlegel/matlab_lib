function k = FindClosestAngle(a,aSearch)
% FindClosestAngle
% 
% Description:	find the closest angle to a in aSearch
% 
% Syntax:	k = FindClosestAngle(a,aSearch)
%
% In:
%	a		- the angles to match
%	aSearch	- the angles to search
% 
% Out:
%	k	- the indices in aSearch of the closest angles to a
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	nA	= numel(a);
	nS	= numel(aSearch);
	
	a		= repmat(reshape(a,1,[]),[nS 1]);
	aSearch	= repmat(reshape(aSearch,[],1),[1 nA]);
	dA		= distAngle(a,aSearch);
	
	[a,k]	= min(dA,[],1);
