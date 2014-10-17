classdef Object < dynamicprops
% Group.Object
% 
% Description:	base object for Group.* objects
% 
% Syntax:	obj = Group.Object(parent,strType,<options>)
%
% 			methods:
%				Start(<options>):	start the object and its attached objects
%				End:				end the object and its attached objects
%				Abort:				abort the object and its attached objects
%				Attach:				attach a Group.Object
%				IsAttached:			test whether a Group.Object is attached
%				IsProp:				test whether a property exists
%
%			properties:
%				type:		the object type
%				started:	true if the object has been started
%
% In:
%	parent			- the parent object
%	strType			- a fieldname-compatible description of the object type
%	<options>:
%		attach_class:	({'Info','Log'}) a cell of class names of objects to
%						attach to the object. the package path for classes in the
%						Group package and in the same package as the object do
%						not need to be specified.
%		attach_name:	(<attach_class>) the property names to give to the
%						objects specified in cAttachClass
%		attach_arg:		(<none>) cells of arguments to pass to each attached
%						class' constructor function
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		started	= false;
		
		type;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		root;
		parent;
		
		children		= {};
		children_name	= {};
		
		argin	= {};
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function obj = Object(parent,strType,varargin)
			opt	= ParseArgs(varargin,...
					'attach_class'	, {'Info','Log'}	, ...
					'attach_name'	, {}				, ...
					'attach_arg'	, {{}}				  ...
					);
			
			opt.attach_name	= unless(opt.attach_name,opt.attach_class);
			opt.attach_arg	= repto(ForceCell(opt.attach_arg),size(opt.attach_class));
			
			obj.parent	= parent;
			obj.root	= obj.GetRoot;
			obj.type	= strType;
			
			%attach the subclasses
				cellfun(@(c,n,a) obj.Attach(c,n,a{:}),ForceCell(opt.attach_class),ForceCell(opt.attach_name),opt.attach_arg);
		end
		%----------------------------------------------------------------------%
		function Start(obj,varargin)
			obj.argin	= append(obj.argin,varargin);
			
			%start the attached objects
				cellfun(@(x) x.Start(obj.argin{:}),obj.children);
			
			obj.started	= true;
		end
		%----------------------------------------------------------------------%
		function End(obj,varargin)
			obj.started	= false;
			
			%end the attached objects
				cellfun(@(x) x.End(varargin{:}),obj.children(end:-1:1));
		end
		%----------------------------------------------------------------------%
		function Abort(obj,varargin)
			obj.End(varargin{:});
		end
		%----------------------------------------------------------------------%
		function Attach(obj,strClass,strName,varargin)
			if ~obj.IsProp(strName)
				cArg	= ParseArgs(varargin,{});
				cArg	= ForceCell(cArg);
				
				[p,c]	= ClassSplit(obj);
				[pp,cp]	= ClassSplit(obj.parent);
				
				import Group.*
				import([p '.*']);
				
				%don't attach an object to itself or its child
					if ~isequal(c,strClass) && ~isequal(cp,strClass)
						addprop(obj,strName);
						
						obj.(strName)		= eval([strClass '(obj,cArg{:})']);
						
						obj.children_name{end+1}	= strName;
						obj.children{end+1}			= obj.(strName);
					end
				%start the object if we've already been started
					if obj.started
						obj.(strName).Start(obj.argin{:});
					end
			end
		end
		%----------------------------------------------------------------------%
		function b = IsAttached(obj,strName)
		%Group.Object.IsAttached
		%
		%test whether a Group.Object is attached
		%
		%Syntax:	b = obj.IsAttached(strName) OR
		%			b = obj.IsAttached(child)
			switch class(strName)
				case 'char'
					b	= ismember(strName,obj.children_name);
				otherwise
					b	= IsMemberCell(strName,obj.children);
			end
		end
		%----------------------------------------------------------------------%
		function b = IsProp(obj,strProp)
		%Group.Object.IsProp
		%
		%test whether a property exists
		%
		%Syntax:	b = obj.IsPropr(strProp)
			b	= ismember(strProp,fieldnames(obj));
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PROTECTED METHODS---------------------------------------------------------%
	methods (Access=protected)
		%----------------------------------------------------------------------%
		function b = IsRoot(obj)
			b	= isempty(obj.parent);
		end
		%----------------------------------------------------------------------%
		function root = GetRoot(obj)
			if isempty(obj.parent)
				root	= obj;
			else
				root	= obj.parent.GetRoot;
			end
		end
		%----------------------------------------------------------------------%
	end
	%PROTECTED METHODS---------------------------------------------------------%
end
