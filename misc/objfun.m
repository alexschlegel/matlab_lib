function varargout = objfun(func,varargin)
% objfun
% 
% Description:	similar to cellfun, but for object arrays
% 
% Syntax:	(see cellfun help)
%
% Note: doesn't work for character arrays
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%make sure we're not dealing with a char
	if isa(varargin{1},'char')
		error('Not implemented for character arrays.  Use arrayfun.');
	end
	
%what class are we dealing with?
	strClass	= class(varargin{1});
%find the last argument of this class
	b		= cellfun('isclass',varargin,strClass);
	kAfter	= find(~b,1,'first');
	if isempty(kAfter)
		kLast	= numel(b);
	else
		kLast	= kAfter - 1;
	end
%make each input array a cell array
	for k=1:kLast
		varargin{k}	= mat2cellByElement(varargin{k});
	end
%use cellfun
	[varargout{1:nargout}]	= cellfun(func,varargin{:});
	