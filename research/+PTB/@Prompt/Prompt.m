classdef Prompt < PTB.Object
% PTB.Prompt
% 
% Description:	use to prompt for information
% 
% Syntax:	pmt = PTB.Prompt
% 
% 			subfunctions:
%				Ask:	ask a question
%				YesNo:	ask a yes/no question
%
%			properties:
%				mode (get only):	the current prompt mode.  one of:
%					'command_window':	show the prompt on the MATLAB command
%										window
%					'ptb_window':		show the prompt on the Psychtoolbox window
% 
% Updated: 2011-12-22
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties (Dependent, SetAccess=private)
		mode;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function strMode = get.mode(pmt)
			if pmt.parent.Window.occludes
				strMode	= 'ptb_window';
			else
				strMode	= 'command_window';
			end
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function pmt = Prompt(parent)
			pmt	= pmt@PTB.Object(parent,'prompt');
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
