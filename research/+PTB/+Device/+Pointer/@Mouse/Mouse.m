classdef Mouse < PTB.Device.Pointer
% PTB.Device.Pointer.Mouse
% 
% Description:	mouse device
% 
% Syntax:	mou = PTB.Device.Pointer.Mouse(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Position:			get the (x,y) position of the mouse, in
%									pixels
%				PositionVA:			get the (x,y) position of the mouse, with
%									origin at the center of the screen and in
%									degrees of visual angle
%				Mode:				get the mouse mode (move, draw, or erase)
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
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%CONSTANT PROPERTIES-------------------------------------------------------%
	properties (Constant)
		IDX_MIDDLE		= 8;
	end
	%CONSTANT PROPERTIES-------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function mou = Mouse(parent)
			mou	= mou@PTB.Device.Pointer(parent,'mouse');
			
			mou.p_default_name	= {'draw';'erase';'left';'middle';'right'};
			mou.p_default_index	= [mou.IDX_DRAW;mou.IDX_ERASE;mou.IDX_DRAW;mou.IDX_MIDDLE;mou.IDX_ERASE];
		end
		%----------------------------------------------------------------------%
		function Start(mou,varargin)
		%mouse start function
			mou.deviceid	= p_GetMouseID;
			
			Start@PTB.Device.Pointer(mou,varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=protected)
		x = GetPointer(mou);
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
