function varargout = p_FixInput(varargin)
% p_FixInput
% 
% Description:	make the inputs all StringMath objects and all of the same size
% 
% Syntax:	[x1,...,xN,bEmptyInput] = p_FixInput(x1,...,xN)
% 
% In:
% 	xK	- the Kth input
% 
% Out:
% 	xK			- the Kth input as a StringMath object and of the correct size
%	bEmptyInput	- true if any of the inputs were empty
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%make StringMath
	[varargout{1:nargin+1}]	= p_FixInputNoResize(varargin{:});
%fix the size
	[varargout{1:nargin}]	= FillSingletonArrays(varargout{:});
	