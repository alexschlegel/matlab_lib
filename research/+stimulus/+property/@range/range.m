classdef range < stimulus.property.generic
% stimulus.property.range
% 
% Description:	a property chosen randomly from a range of values
% 
% Syntax: obj = stimulus.property.range(xBound,<options>)
% 
% Methods:
%	set:	set the property value
%	get:	get the property value
% 
% Properties:
%	bound:		a two-element array specifying the lower and upper bound of the
%				range of values from which to choose
%	size:		the size of the array to generate
%	exclude:	an array of values to exclude when choosing a property value
% 
% In:
%	xBound	- the initial <bound> property value
%	<options>:
%		size:		([1 1]) the initial value of the <size> property
%		exclude:	([]) the initial value of the <exclude> property
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%PUBLIC
		properties (SetAccess=public, GetAccess=public)
			bound;
			size;
		end
%/PROPERTIES--------------------------------------------------------------------

%PROPERTY GET/SET---------------------------------------------------------------
	methods
		function x = get.bound(obj)
			x	= obj.bound.get;
		end
		function obj = set.bound(obj,x)
			obj.bound	= stimulus.property.generic(x);
		end
		
		function x = get.size(obj)
			x	= obj.size.get;
		end
		function obj = set.size(obj,x)
			obj.size	= stimulus.property.generic(x);
		end
	end
%/PROPERTY GET/SET--------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = range(xBound,varargin)
				obj = obj@stimulus.property.generic([],varargin{:});
				
				opt	= ParseArgs(varargin,...
						'size'	, [1 1]	  ...
						);
				
				obj.bound	= xBound;
				obj.size	= opt.size;
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			value = generate(obj)
			b = test_exclude(obj,value)
		end
%/METHODS-----------------------------------------------------------------------

end
