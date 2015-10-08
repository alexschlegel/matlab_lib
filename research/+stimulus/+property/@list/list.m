classdef list < stimulus.property.generic
% stimulus.property.list
% 
% Description:	a property chosen randomly from a list of values
% 
% Syntax: obj = stimulus.property.list(xValues,<options>)
% 
% Methods:
%	set:	set the property value
%	get:	get the property value
% 
% Properties:
%	values:		an array specifying the values from which to choose
%	size:		the size of the array to generate
%	exclude:	an array of values to exclude when choosing a property value
% 
% In:
%	xValues	- the initial <values> property value
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
			values;
			size;
		end
%/PROPERTIES--------------------------------------------------------------------

%PROPERTY GET/SET---------------------------------------------------------------
	methods
		function x = get.values(obj)
			x	= obj.values.get;
		end
		function obj = set.values(obj,x)
			obj.values	= stimulus.property.generic(x);
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
			function obj = list(xValues,varargin)
				obj = obj@stimulus.property.generic([],varargin{:});
				
				opt	= ParseArgs(varargin,...
						'size'	, [1 1]	  ...
						);
				
				obj.values	= xValues;
				obj.size	= opt.size;
			end
		end
	
		methods (Access=protected)
			value = generate(obj)
			b = test_exclude(obj,value)
		end
%/METHODS-----------------------------------------------------------------------

end
