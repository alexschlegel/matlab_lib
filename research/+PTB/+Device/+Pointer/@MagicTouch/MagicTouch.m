classdef MagicTouch < PTB.Device.Pointer
% PTB.Device.Pointer.MagicTouch
% 
% Description:	magictouch fMRI-compatible drawing tablet device
% 
% Syntax:	mag = PTB.Device.Pointer.MagicTouch(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Position:			get the (x,y) position of the device, in
%									pixels
%				PositionVA:			get the (x,y) position of the device,
%									with origin at the center of the screen and
%									in degrees of visual angle
%				Mode:				get the device mode (move, draw, or erase)
%				Down:				check to see if a button is down
%				DownOnce:			check to see if a button is down, only
%									returning true once per press
%				Pressed:			check to see if a button was pressed
%				State:				get the state of the device
%				Get:				get the state indices associated with a
%									named button
%				Set:				set the state indices associated with a
%									named button
%				ButtonNames:		get the names of all defined buttons
%				SetBase:			set the base state of the input device
% 
% In:
%	parent	- the parent object
% 	<options>:
%		magictouch_button_mode:	('de') the mode for the magictouch buttons.  one
%								of the following:
%									'de':	the left input button toggles
%											between draw and erase modes
%									'mde':	the left button toggles between move
%											and draw modes and the right button
%											toggles between move and erase modes
%		magictouch_alt_button:	(false) true if left and right arrow keys on a
%								should also work as left and right buttons 
% 
% Updated: 2015-06-12
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%CONSTANT PROPERTIES-------------------------------------------------------%
	properties (Constant)
		BUT_NONE	= 0;
		BUT_LEFT	= 1;
		BUT_RIGHT	= 2;
	end
	%CONSTANT PROPERTIES-------------------------------------------------------%
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		butlast		= 0;
		modelast	= PTB.Device.Pointer.MODE_DRAW;
		
		key	= [];
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function mag = MagicTouch(parent)
			mag	= mag@PTB.Device.Pointer(parent,'magictouch');
		end
		%----------------------------------------------------------------------%
		function Start(mag,varargin)
		%magictouch start function
			opt	= ParseArgs(varargin,...
					'magictouch_button_mode'	, 'de'	, ...
					'magictouch_alt_button'		, false	  ...
					);
			
			opt.magictouch_button_mode	= CheckInput(opt.magictouch_button_mode,'magictouch button mode',{'de','mde'});
			
			mag.deviceid	= p_GetMagicTouchID;
			
			mag.parent.Info.Set('magictouch',{'button','mode'},opt.magictouch_button_mode,'replace',false);
			mag.parent.Info.Set('magictouch',{'button','alt'},opt.magictouch_alt_button,'replace',false);
			
			if mag.parent.Info.Get('magictouch',{'button','alt'})
				mag.key	= PTB.Device.Input.Keyboard(mag.parent);
				
				mag.key.Start;
			end
			
			Start@PTB.Device.Pointer(mag,varargin{:});
		end
		%----------------------------------------------------------------------%
		function End(mag,varargin)
		%magictouch end function
			if ~isempty(mag.key)
				mag.key.End;
			end
			
			End@PTB.Device.Pointer(mag,varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=protected)
		x = GetPointer(mag);
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
