classdef collection < handle
% stimulus.property.collection
% 
% Description:	a collection of properties
% 
% Syntax: obj = stimulus.property.collection([prop]=<none>)
% 
% Methods:
%	add:	add a property to the collection
% 
% Properties:
%	:	
% 
% In:
%	[prop]	- a struct defining the initial properties to include in the
%			  collection. each field defines a property with the same name as
%			  the field. each field should be a struct with the following
%			  fields:
%				type:	a valid property type (e.g. 'generic' 'range')
%				arg:	a cell of values to pass as arguments to the property
%						class constructor
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%PRIVATE
		properties (SetAccess=protected, GetAccess=protected)
			prop	= struct;
		end
%/PROPERTIES--------------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = collection(varargin)
				obj = obj@handle();
				
				%parse the inputs
					prop	= ParseArgs(varargin,struct);
					
					cField	= fieldnames(prop);
					nField	= numel(cField);
					for kF=1:nField
						strProp	= cField{kF};
						
						strType	= prop.(strProp).type;
						cArg	= prop.(strProp).arg;
						
						obj.add(cField{kF},strType,cArg);
					end
			end
		end
	
	%PRIVATE
		methods (Access=protected)
		
		end
%/METHODS-----------------------------------------------------------------------

end
