function varargout = FillAllButSingletonArrays(varargin)
% FillAllButSingletonArrays
% 
% Description:	fill unfull arrays to be the same size as the largest arrays,
%				excluding singleton arrays
% 
% Syntax:	[x1,...,xN] = FillAllButSingletonArrays(x1,...,xN)
% 
% In:
% 	xK	- an array or cell that either has one element or is the same size as
%		  all other non-singleton arrays/cells
% 
% Out:
% 	xK	- see description
% 
% Updated:	2010-05-03
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the size of the output arrays
	s		= cellfun(@size,varargin,'UniformOutput',false)';
	nd		= cellfun(@ndims,varargin,'UniformOutput',false)';
	ndMax	= max(cell2mat(nd));
	s		= cellfun(@(x,y) [x ones(1,ndMax-y)],s,nd,'UniformOutput',false);
	sMax	= max(cell2mat(s));
%fill unfill dimensions of each array
	varargout	= varargin;
	
	bFill				= ~cellfun(@isscalar,varargin);
	varargout(bFill)	= cellfun(@(x,y) repmat(x,sMax-y+1),varargin(bFill)',s(bFill),'UniformOutput',false);
