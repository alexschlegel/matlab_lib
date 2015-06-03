classdef Object < handle
% MVPA.Object
% 
% Description:	base MVPA object class
% 
% Syntax:	obj = MVPA.Object([propBase]={})
%
% Updated: 2015-06-03
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected)
		option;
	end
	properties (SetAccess=protected, GetAccess=protected)
		%base properties of the object that should not be included in the
		%options struct
			base_properties	= {};
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%DERIVED PROPERTIES--------------------------------------------------------%
	methods
		function opt = get.option(obj)
			cOption	= setdiff(properties(obj),obj.base_properties);
			nOption	= numel(cOption);
			
			for kO=1:nOption
				opt.(cOption{kO})	= obj.(cOption{kO});
			end
			
			opt.object_class	= class(obj);
		end
	end
	%DERIVED PROPERTIES--------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function obj = Object(varargin)
			if nargin>0
				propBase	= varargin{1};
				
				if ~iscell(propBase)
					propBase	= {propBase};
				end
			else
				propBase	= {};
			end
			
			obj.base_properties	= ['option'; reshape(propBase,[],1)];
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
