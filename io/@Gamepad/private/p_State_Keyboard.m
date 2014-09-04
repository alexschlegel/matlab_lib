function bState = p_State_Keyboard(gp)
% p_State_Keyboard
% 
% Description:	get the state of the keyboard
% 
% Syntax:	bState = p_State_Keyboard(gp)
% 
% In:
% 	gp	- the gamepad object
% 
% Out:
% 	bState	- see KbState
% 
% Updated: 2011-09-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[d,d,bState]	= KbCheck;
bState			= reshape(bState,[],1);
