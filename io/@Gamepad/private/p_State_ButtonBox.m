function bState = p_State_ButtonBox(gp)
% p_State_ButtonBox
% 
% Description:	get the state of the keyboard
% 
% Syntax:	bState = p_State_ButtonBox(gp)
% 
% In:
% 	gp	- the gamepad object
% 
% Out:
% 	bState	- a 255x1 logical array specifying which bytes were read from the
%			  serial port
% 
% Updated: 2011-09-13
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bState	= false(255,1);

[d,tRead,strErr]	= IOPort('Read',gp.param.h);
bState(d)			= true;

if ~isempty(strErr)
	status(['IOPort Error: ' strErr],'warning',true);
end

