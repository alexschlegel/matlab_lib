function bState = p_State_Gamepad(obj)
% p_State_Gamepad
% 
% Description:	get the state of the gamepad
% 
% Syntax:	bState = p_State_Gamepad(gp)
% 
% In:
% 	gp	- the gamepad object
% 
% Out:
% 	bState	- see JoyMEX
% 
% Updated: 2011-09-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[axes,bState]	= JoyMEX(obj.padID);
bState			= reshape(bState,[],1);
