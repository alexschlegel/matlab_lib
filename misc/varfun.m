function varargout = varfun(f,varargin)
% varfun
% 
% Description:	perform a function on several variables, returning the results
% 
% Syntax:	[y1,...,yN] = varfun(f,x1,...,xN,['UniformOutput',false]) OR
%			y           = varfun(f,x1,...,xN,'UniformOutput',true)
% 
% In:
%	f			- a function that takes one input and returns one output
% 	xK			- the Kth variable
% 
% Out:
% 	yK	- f(xK)
%	y	- an array of f(xK)s
% 
% Updated: 2010-09-15
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the return type
	bUniform	= false;
	if nargin>3
		if ischar(varargin{end-1}) && isequal(lower(varargin{end-1}),'uniformoutput')
			bUniform	= varargin{end};
			varargin	= varargin(1:end-2);
		end
	end
%evaluate
	if bUniform
		varargout{1}	= cellfun(f,varargin);
	else
		varargout		= cellfun(f,varargin,'UniformOutput',false);
	end
