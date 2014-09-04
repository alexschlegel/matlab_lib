function [c,k] = GroupContiguous(x)
% GroupContiguous
% 
% Description:	group elements of integer array x into contiguous blocks
% 
% Syntax:	[c,k] = GroupContiguous(x)
% 
% In:
% 	x	- an array of integers
% 
% Out:
% 	c	- a cell of arrays of contiguous, sorted elements of x.  NaNs are placed
%		  together in the last group
%	k	- a cell of the indices of the elements of c in the original array x
% 
% Updated: 2010-09-09
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%sort x
	[x,kSort]	= sort(x(:));
%determine the groupings
	d		= reshape(x(2:end) - x(1:end-1),[],1);
	
	kNaN	= find(isnan(x),1,'first')-1;
	kNaN	= conditional(kNaN~=0,kNaN,[]);
	
	kBreak	= [find(d>1); kNaN];
	
	kStart	= [1; kBreak+1];
	kEnd	= [kBreak; numel(x)];
%group
	kGroup	= arrayfun(@(kS,kE) kS:kE,kStart,kEnd,'UniformOutput',false);
	c		= cellfun(@(k) x(k),kGroup,'UniformOutput',false);
	k		= cellfun(@(k) kSort(k),kGroup,'UniformOutput',false);
