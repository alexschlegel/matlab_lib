classdef Prompt < Group.Object
% Group.Prompt
% 
% Description:	prompt for information
% 
% Syntax:	pmt = Group.Prompt
% 
% 			subfunctions:
%				Ask:	ask a question
%				YesNo:	ask a yes/no question
%
%			properties:
%				mode (get only):	the current prompt mode.  one of:
%					'command_window':	show the prompt on the MATLAB command
%										window
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties (Dependent, SetAccess=private)
		mode;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function strMode = get.mode(pmt)
			strMode	= 'command_window';
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function pmt = Prompt(parent,varargin)
			[strType,opt]	= ParseArgs(varargin,'prompt',...
								'attach_class'	, []	, ...
								'attach_name'	, []	, ...
								'attach_arg'	, []	  ...
								);
			cOpt			= opt2cell(opt);
			
			pmt	= pmt@Group.Object(parent,strType,cOpt{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
