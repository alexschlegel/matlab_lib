classdef Joystick < PTB.Device.Input
% PTB.Device.Input.Joystick
% 
% Description:	joystick input device (only supports the Logitech F310; requires
%				Simulink 3D Animation) 
% 
% Syntax:	joy = PTB.Device.Input.Joystick(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Down:				check to see if a button is down
%				DownOnce:			check to see if a button is down, only
%									returning true once per press
%				Pressed:			check to see if a button was pressed
%				State:				get the state of the joystick
%				Get:				get the state indices associated with a named
%									button
%				Set:				set the state indices associated with a named
%									button
%				SetBase:			set the base state of the joystick
% 
% In:
%	parent	- the parent object
% 	<options>:
%		input_scheme:	('lr') the input scheme, to determine preset mappings.
%						one of the following:
%							lr:
%									left:	ltrigger
%									right:	rtrigger
%							lrud:
%									left:	x
%									right:	b
%									up:		y
%									down:	a
% Updated: 2012-01-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		joy;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function joy = Joystick(parent)
			joy	= joy@PTB.Device.Input(parent,'joystick');
			
			joy.p_default_name	=	{
										'a'
										'b'
										'x'
										'y'
										'ltrigger'
										'lupper'
										'rtrigger'
										'rupper'
										'back'
										'start'
									};
			joy.p_default_index	=	[
										1
										2
										3
										4
										5
										5
										6
										6
										7
										8
									];
			
			joy.p_scheme			=	{
											'lr'	{
														{'left'		'ltrigger'	[]}
														{'right'	'rtrigger'	[]}
													}
											'lrud'	{
														{'left'		'x'			[]}
														{'right'	'b'			[]}
														{'up'		'y'			[]}
														{'down'		'a'			[]}
													}
										};
			joy.p_scheme_default	= 'lr';
		end
		%----------------------------------------------------------------------%
		function Start(joy,varargin)
		%joystick start function
			joy.joy	= vrjoystick(1);
			
			Start@PTB.Device.Input(joy,varargin{:});
			
			s	= joy.State;
			joy.SetBase([false(11,1); s(12:19)]);
		end
		%----------------------------------------------------------------------%
		function End(joy,varargin)
		%joystick end function
			End@PTB.Device.Input(joy,varargin{:});
			
			try
				close(joy.joy);
			catch me
				joy.AddLog('error closing joystick');
			end
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
