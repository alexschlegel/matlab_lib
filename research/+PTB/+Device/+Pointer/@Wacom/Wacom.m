classdef Wacom < PTB.Device.Pointer
% PTB.Device.Pointer.Wacom
% 
% Description:	wacom device
% 
% Syntax:	wac = PTB.Device.Pointer.Wacom(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Position:			get the (x,y) position of the wacom device, in
%									pixels
%				PositionVA:			get the (x,y) position of the wacom device,
%									with origin at the center of the screen and in
%									degrees of visual angle
%				Pressure:			get the pressure of the wacom stylus
%				Tilt:				get the (x,y) tilt of the wacom stylus
%				Mode:				get the wacom device mode (move, draw, or
%									erase)
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
% 	<options>:
% 
% Updated: 2012-07-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		last	= struct;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function wac = Wacom(parent)
			wac	= wac@PTB.Device.Pointer(parent,'wacom');
			
			wac.last		= dealstruct('stylus','eraser','touch',struct('x',0,'y',0,'button',0,'p',0,'tx',0,'ty',0));
			wac.last.mode	= 1;
		end
		%----------------------------------------------------------------------%
		function Start(wac,varargin)
		%wacom start function
			wac.deviceid	= p_GetWacomIDs;
			
			p_InitializeState(wac);
			
			Start@PTB.Device.Pointer(wac,varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=protected)
		x = GetPointer(wac);
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
