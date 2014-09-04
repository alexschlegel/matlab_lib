classdef Element < handle
% Yafaray.Element
% 
% Description:	a yafaray element
% 
% Syntax:	e = Yafaray.Element(strType,[strName]=<none>,[val]=<none>,[sAttribute]=<none>)
%			
%			properties:
%				name		- the element name
%				value		- the element value
%				type		- (get only) the element type
%				xml			- (get only) an xml struct of the element contents
%				string		- (get only) an xml string of the element contents
%				attribute	- (protected) a struct of other element attributes
%				child		- (protected) an array of Yafray.Element children
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
		name		= [];
		value		= [];
	end
	properties (SetAccess=protected)
		type		= '';
		
		xml;
		string;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		child		= [];
		attribute	= struct;
		
		changed	= true;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function e = set.type(e,strType)
			if ischar(strType)
				e.changed	= true;
				e.type		= strType;
			else
				error('element type must be a string.');
			end
		end
		
		function e = set.name(e,strName)
			if ischar(strName)
				e.changed	= true;
				e.name		= strName;
			else
				error('element name must be a string.');
			end
		end
		
		function e = set.value(e,val)
			if ~isempty(val)
			%make sure we got a good value
				[cType,cVal] = p_ParseValue(val);
			end
			
			e.changed	= true;
			e.value		= val;
		end
		
		function e = set.attribute(e,attrib)
			if isempty(attrib)
				attrib	= struct;
			end
			
			if isstruct(attrib)
				e.changed	= true;
				e.attribute	= attrib;
			else
				error('element attributes must be represented as a struct.');
			end
		end
		
		function e = set.child(e,c)
			if isempty(c)
				c	= [];
			end
			
			if isa(c,'Yafaray.Element') || isempty(c)
				e.changed	= true;
				e.child		= c;
			else
				error('element children must be Yafaray.Elements.');
			end
		end
		
		function xml = get.xml(e)
			if e.changed
				[e.xml,e.string]	= p_ParseXML(e);
				e.changed			= false;
			end
			
			xml	= e.xml;
		end
		function string = get.string(e)
			if e.changed
				[e.xml,e.string]	= p_ParseXML(e);
				e.changed			= false;
			end
			
			string	= e.string;
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function e = Element(strType,varargin)
			[strName,val,sAttribute]	= ParseArgs(varargin,'',[],struct);
			
			e.type		= strType;
			e.name		= strName;
			e.value		= val;
			e.attribute	= sAttribute;
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
