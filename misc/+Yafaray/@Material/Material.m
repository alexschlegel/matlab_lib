classdef Material < Yafaray.Element
% Yafaray.Material
% 
% Description:	a yafaray material element
% 
% Syntax:	mat = Yafaray.Material(strName,<options>)
%			
%			properties:
%				name		- the material name
%				xml			- (get only) an xml struct of the element contents
%				string		- (get only) an xml string of the element contents
%
% In:
%	strType			- the element type
%	[strName]		- the element name
%	[val]			- the element value
%	[sAttribute]	- a struct of other element attributes
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	properties (SetAccess=protected)
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function mat = Material(strName,varargin)
			%opt	= ParseArgs(varargin,'',[],struct);
			
			mat	= mat@Yafaray.Element('material',strName);
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
