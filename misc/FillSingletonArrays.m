function varargout = FillSingletonArrays(varargin)
% FillSingletonArrays
% 
% Description:	fill unfull arrays to be the same size as the largest arrays
% 
% Syntax:	[x1,...,xN] = FillSingletonArrays(x1,...,xN)
% 
% In:
% 	xK	- an array or cell that either has one element or is the same size as
%		  all other non-singleton arrays/cells
% 
% Out:
% 	xK	- the filled array
% 
% Updated:	2011-11-14
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

% if any(cellfun(@isempty,varargin))
% 	varargout	= cellfun(@(x) x([]),varargin,'UniformOutput',false);
% 	return;
% end

%reshape for happiness
	varargin	= reshape(varargin,[],1);
	nIn			= nargin;
%get the size of the output arrays
	ndMax	= max(cellfun(@ndims,varargin));
	s		= cellfun(@(x) [size(x) ones(1,ndMax-ndims(x))],varargin,'UniformOutput',false);
	sm		= cell2mat(s);
	sMax	= max(sm,[],1);
%enclose arrays with unfull, non-singleton dimensions in cells
	bUnfull				= any(sm>1 & sm<repmat(sMax,[nIn 1]),2);
	varargin(bUnfull)	= cellfun(@(x) {x},varargin(bUnfull),'UniformOutput',false);
	s(bUnfull)			= {[1 1]};
	
	if any(bUnfull)
		ndMax	= max(cellfun(@ndims,varargin));
		s		= cellfun(@(x) [size(x) ones(1,ndMax-ndims(x))],varargin,'UniformOutput',false);
		sm		= cell2mat(s);
		sMax	= max(sm);
	end
%fill unfull dimensions of each array
	varargout	= cellfun(@(x,s1) repmat(x,sMax-s1+1),varargin,s,'UniformOutput',false);
