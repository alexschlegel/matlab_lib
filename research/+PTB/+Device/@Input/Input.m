classdef Input < PTB.Object
% PTB.Device.Input
% 
% Description:	base class for input devices
% 
% Syntax:	inp = PTB.Device.Input(parent,strType)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Down:				check to see if a button is down
%				DownOnce:			check to see if a button is down, only
%									returning true once per press
%				Pressed:			check to see if a button was pressed
%				State:				get the state of the device
%				Get:				get the state indices associated with a named
%									button
%				Set:				set the state indices associated with a named
%									button
%				ButtonNames:		get the names of all defined buttons
%				SetBase:			set the base state of the input device
% 
% In:
%	parent	- the parent object
%	strType	- a short, fieldname-compatible description of the input type
% 	<options>:
%		input_scheme(<default>) the input scheme, to determine preset mappings
% 
% Updated: 2011-12-24
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%CONSTANT PROPERTIES-------------------------------------------------------%
	properties (Constant)
		
	end
	%CONSTANT PROPERTIES-------------------------------------------------------%

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties (SetAccess=protected)
		p_default_name		= {};
		p_default_index		= [];
		p_scheme			= cell(0,2);
		p_scheme_default	= '';
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		state	= dealstruct('downonce','pressed',dealstruct('wasdown','wasup',[]));
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function inp = Input(parent,strType)
			inp	= inp@PTB.Object(parent,strType);
		end
		%----------------------------------------------------------------------%
		function Start(inp,varargin)
		%default input start function
			opt	= ParseArgs(varargin,...
					'input_scheme'	, inp.p_scheme_default	  ...
					);
			
			inp.parent.Info.Set('input',{inp.type,'button'},struct,'replace',false);
			
			if ~isempty(inp.p_scheme)
				opt.input_scheme	= CheckInput(opt.input_scheme,'input_scheme',inp.p_scheme(:,1));
			end
			
			%set the base state
				if isempty(inp.parent.Info.Get('input',{inp.type,'basestate'}))
					inp.SetBase(false);
					s	= inp.State;
					inp.SetBase(false(size(s)));
				end
			%set the default keys
				cellfun(@(str,k) inp.Set(str,k,[],false),inp.p_default_name,num2cell(inp.p_default_index));
			%set the 'all', 'any', and 'none' buttons
				kAll	= reshape(unique(inp.p_default_index),[],1);
				
				inp.Set('all',kAll);
				inp.Set('any',kAll');
				inp.Set('none',{},kAll');
			%set the scheme buttons
				[bScheme,kScheme]	= ismember(opt.input_scheme,inp.p_scheme(:,1));
				
				if bScheme
					cellfun(@(x) inp.Set(x{:},false),inp.p_scheme{kScheme,2});
				end
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
