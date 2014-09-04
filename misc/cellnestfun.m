function varargout = cellnestfun(f,varargin)
% cellnestfun
% 
% Description:	evaluate a function on each non-cell element of a nested cell
% 
% Syntax:	[co1,...,coM] = cellnestfun(f,ci1,...,ciN)
% 
% In:
% 	f	- the handle to a function that takes N inputs and returns M outputs
%	ciK	- the Kth nested cell (e.g. {{1,2},{3,{{4,5},6}},7}
% 
% Out:
% 	coK	- a nested cell of the Kth outputs from the function
% 
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if all(cellfun(@iscell,varargin))
	[varargout{1:nargout}]	= cellfun(@(varargin) cellnestfun(f,varargin{:}),varargin{:},'UniformOutput',false);
else
	[varargout{1:nargout}]	= f(varargin{:});
end
