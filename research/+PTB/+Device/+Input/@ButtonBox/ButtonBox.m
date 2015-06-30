classdef ButtonBox < PTB.Device.Input
% PTB.Device.Input.ButtonBox
% 
% Description:	button box input device
% 
% Syntax:	key = PTB.Device.Input.ButtonBox(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Down:				check to see if a button was pressed (same as
%									Pressed)
%				DownOnce:			check to see if a button is down, only
%									returning true once per press (same as
%									Pressed)
%				Pressed:			check to see if a button was pressed
%				State:				get the state of the button box
%				Get:				get the state indices associated with a named
%									button
%				Set:				set the state indices associated with a named
%									button
%				SetBase:			set the base state of the button box
% 
% In:
%	parent	- the parent object
% 	<options>:
%		input_scheme:	('lr') the input scheme, to determine preset mappings.
%						one of the following:
%							lr: (blue/yellow or green/red button box)
%								left:	blue or green
%								right:	yellow or red
%							llrr: (both two button boxes)
%								lleft:	blue
%								rleft:	yellow
%								lright:	green
%								rright:	red
%							lrud: (four button box)
%								left:	yellow
%								right:	green
%								up:		blue
%								down:	red
%		buttonbox_alt:	(true) true to set keyboard keys to simulate buttonbox
%						responses
% 
% Updated: 2015-06-12
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		Key;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function bb = ButtonBox(parent)
			bb	= bb@PTB.Device.Input(parent,'buttonbox');
			
			bb.p_default_name	=	{
										'blue'
										'yellow'
										'green'
										'red'
									};
			bb.p_default_index	=	[
										PTB.Device.Scanner.SCANNER_BB_BLUE
										PTB.Device.Scanner.SCANNER_BB_YELLOW
										PTB.Device.Scanner.SCANNER_BB_GREEN
										PTB.Device.Scanner.SCANNER_BB_RED
									];
			
			bb.p_scheme			=	{
										'lr'	{
													{'left'		{'blue','green'}	[]}
													{'right'	{'yellow','red'}	[]}
												}
										'llrr'	{
													{'lleft'	'blue'				[]}
													{'rleft'	'yellow'			[]}
													{'lright'	'green'				[]}
													{'rright'	'red'				[]}
												}
										'lrud'	{
													{'left'		'yellow'			[]}
													{'right'	'green'				[]}
													{'up'		'blue'				[]}
													{'down'		'red'				[]}
												}
									};
			bb.p_scheme_default	= 'lr';
		end
		%----------------------------------------------------------------------%
		function Start(bb,varargin)
		%buttonbox start function
			opt	= ParseArgs(varargin,...
					'buttonbox_alt'	, true	  ...
					);
			
			bb.parent.Info.Set('input',{bb.type,'alt'},opt.buttonbox_alt,'replace',false);
			
			if bb.parent.Info.Get('input',{bb.type,'alt'})
			%set up the keyboard for checking for keys
				strInputMode	= bb.parent.Info.Get('experiment','input');
				if ~isequal(strInputMode,'keyboard')
					bb.Key	= PTB.Device.Input.Keyboard(bb.parent);
					bb.Key.Start;
				else
					bb.Key	= bb.parent.Input;
				end
				
				bb.Key.Set('bb_blue',bb.Key.Get('key_f9'),[],false);
				bb.Key.Set('bb_yellow',bb.Key.Get('key_f10'),[],false);
				bb.Key.Set('bb_green',bb.Key.Get('key_f11'),[],false);
				bb.Key.Set('bb_red',bb.Key.Get('key_f12'),[],false);
				bb.Key.Set('bb_any',{'bb_blue','bb_yellow','bb_green','bb_red'},[],false);
				
				bb.AddLog('F9: blue/up/lleft');
				bb.AddLog('F10: yellow/left/rleft');
				bb.AddLog('F11: green/right/lright');
				bb.AddLog('F12: red/down/rright');
			end
			
			Start@PTB.Device.Input(bb,varargin{:});
		end
		%----------------------------------------------------------------------%
		function End(bb,varargin)
		%buttonbox end function
			End@PTB.Device.Input(bb,varargin{:});
			
			%end the subobjects
				if bb.parent.Info.Get('input',{bb.type,'alt'}) && ~isequal(bb.parent.Info.Get('experiment','input'),'keyboard')
					bb.Key.End(varargin{:});
				end
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
