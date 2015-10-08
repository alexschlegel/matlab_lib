classdef generic
% stimulus.property.generic
% 
% Description:	a generic property
% 
% Syntax: obj = stimulus.property.generic(value,<options>)
% 
% Methods:
%	set:	set the property value
%	get:	get the property value
% 
% Properties:
%	exclude:	an array of values to exclude when choosing a property value
%	timeout:	the amount of time, in milliseconds, to attempt to generate
%				the property value before failing
% 
% In:
%	value	- the property value, or a function that takes either no arguments
%			  or takes the exclude property as an option (i.e.
%			  value('exclude',obj.exclude) ) and returns the value
%	<options>:
%		exclude:	([]) the initial value of the <exclude> property
%		timeout:	(10000) the initial value of the <timeout> property
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%PUBLIC
		properties (SetAccess=public, GetAccess=public)
			exclude;
			timeout;
		end
	
	%PRIVATE
		properties (SetAccess=protected, GetAccess=protected)
			value;
			
			valueType;
		end
	
	%PRIVATE CONSTANTS
		properties (Constant, SetAccess=protected, GetAccess=protected)
			VALUE_EXPLICIT		= 0;
			VALUE_FUNC_NOARG	= 1;
			VALUE_FUNC_EXCLUDE	= 2;
		end
%/PROPERTIES--------------------------------------------------------------------

%PROPERTY GET/SET---------------------------------------------------------------
	methods
		function x = get.value(obj)
			x	= obj.value;
		end
		function obj = set.value(obj,x)
			obj.value	= x;
			
			if isa(x,'function_handle');
				if nargin(x)==0
					obj.valueType	= obj.VALUE_FUNC_NOARG;
				else
					obj.valueType	= obj.VALUE_FUNC_EXCLUDE;
				end
			else
				obj.valueType	= obj.VALUE_EXPLICIT;
			end
		end
	end
%/PROPERTY GET/SET--------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = generic(value,varargin)
				opt	= ParseArgs(varargin,...
						'exclude'	, []	, ...
						'timeout'	, 10000	  ...
						);
				
				obj.value	= value;
				obj.exclude	= opt.exclude;
				obj.timeout	= opt.timeout;
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			value = generate(obj)
			b = test_exclude(obj,value)
		end
%/METHODS-----------------------------------------------------------------------

end
