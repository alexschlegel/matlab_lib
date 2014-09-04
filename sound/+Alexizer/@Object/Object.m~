classdef Object < dynamicprops
% PTB.Object
% 
% Description:	the base class for PTB classes
% 
% Syntax:	obj = PTB.Object
%
% 			subfunctions:
% 				Start(<options>):	start the object and its children
%				End:				end the object and its children
%				SetParent:			set the parent object
%				AddChild:			add a child PTB.Object
%				RemoveChild:		remove a child PTB.Object
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected)
		parent;
		children	= {};
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		type;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function obj = Object(parent,strType)
			obj.parent	= parent;
			obj.type	= strType;
		end
		%----------------------------------------------------------------------%
		function Start(obj,varargin)
			%start the children
				nChild	= numel(obj.children);
				for kC=1:nChild
					obj.children{kC}.Start(varargin{:});
				end
		end
		%----------------------------------------------------------------------%
		function End(obj,varargin)
			%end the children!
				nChild	= numel(obj.children);
				for kC=1:nChild
					obj.children{kC}.End(varargin{:});
				end
		end
		%----------------------------------------------------------------------%
		function AddLog(obj,varargin)
			obj.parent.Log.Append(obj.type,varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
