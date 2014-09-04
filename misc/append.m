function [x,n] = append(varargin)
% append
% 
% Description:	concatenate a set of arrays along their last occupied dimension
%				each array must be identically-sized until the last occupied
%				dimension.
% 
% Syntax:	[x,n] = append(x1,...,xN)
% 
% In:
%	xK	- the Kth array
% 
% Out:
%	x	- the stacked array
%	n	- the dimension along which the arrays were appended
% 
% Updated: 2010-12-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if nargin>0
	k	= find(~cellfun(@isempty,varargin),1);
	
	if isempty(k)
		if nargin>0
			x	= varargin{1};
		else
			x	= [];
		end
		
		n	= 1;
		return;
	else
		s	= size(varargin{k});
		n	= find(s~=1,1,'last');
		if isempty(n)
			n	= 1;
		end
	end
else
	n	= 0;
end

x	= cat(n,varargin{:});
