classdef AutoBahx < PTB.Device.Input & AutoBahx
% PTB.Device.Input.AutoBahx
% 
% Description:	AutoBahx input device 
% 
% Syntax:	ab = PTB.Device.Input.AutoBahx(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Down:				check to see if a button is down
%				DownOnce:			check to see if a button is down, only
%									returning true once per press
%				Pressed:			check to see if a button was pressed
%				State:				get the state of the AutoBahx
%				Get:				get the state indices associated with a named
%									button
%				Set:				set the state indices associated with a named
%									button
%				SetBase:			set the base state of the AutoBahx
%				Press: 				press the AutoBahx button for a set amount of
%									time
%				GetTimes:			get the button down and up times that have
%									occurred since the last call to GetTimes
%				PauseCalibration:	pause the autocalibration timer
%				ResumeCalibration:	resume the autocalibration timer
%				Calibrate:			manually perform a time calibration step
% 
% 			properties:
% 				color (get/set):	the button LED (r,g,b) color (0->255)
%				button (get/set):	the button state (either boolean for on/off
%									or a number from 0->1 for partial activation
%									(not recommended)
%				opened (get):		true if the serial link with the AutoBahx is
%									opened
%				calibrating (get):	true if the autocalibration timer is enabled
%
%			constants:
%				BAUDRATE:		the baud rate used for communicating with the
%								AutoBahx
%				T_PRESS_MAX:	the maximum Press time, in ms
%
% In:
%	parent	- the parent object
% 	<options>:
%		input_scheme:	('lr') the input scheme, to determine preset mappings.
%						one of the following:
%							lr:
%									left:	button
%									right:	button
%							lrud:
%									left:	button
%									right:	button
%									up:		button
%									down:	button
% Updated: 2012-03-23
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function ab = AutoBahx(parent)
			ab	= ab@PTB.Device.Input(parent,'autobahx');
			
			ab.p_default_name	=	{
										'button'
									};
			ab.p_default_index	=	[
										1
									];
			
			ab.p_scheme			=	{
										'lr'	{
													{'left'		'button'	[]}
													{'right'	'button'	[]}
												}
										'lrud'	{
													{'left'		'button'	[]}
													{'right'	'button'	[]}
													{'up'		'button'	[]}
													{'down'		'button'	[]}
												}
									};
			ab.p_scheme_default	= 'lr';
		end
		%----------------------------------------------------------------------%
		function Start(ab,varargin)
		%autobahx start function
			ab.parent.Info.Set('input',{ab.type,'last'},false,'replace',false);
			
			Start@PTB.Device.Input(ab,varargin{:});
			
			ab.SetBase(false);
		end
		%----------------------------------------------------------------------%
		function End(ab,varargin)
		%autobahx end function
			End@PTB.Device.Input(ab,varargin{:});
			
			try
				delete(ab);
			catch me
				ab.AddLog('error deleting autobahx');
			end
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
