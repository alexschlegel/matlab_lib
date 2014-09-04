function varargout = size2(x,varargin)
% size2
% 
% Description:	size of x, correct for scalars and empty arrays
% 
% Syntax:	[...] = size2(x,...) (see size help) 
% 
% Updated: 2010-05-04
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
varargout	= cell(max(nargout,1),1);

if isempty(x)
	[varargout{:}]	= deal([]);
elseif isscalar(x)
	[varargout{:}]	= deal(1);
else
	[varargout{:}]	= size(x,varargin{:});
end
