function gp = p_Init_Gamepad(gp,nGP)
% p_Init_Gamepad
% 
% Description:	init a gamepad
% 
% Syntax:	gp = p_Init_Gamepad(gp,nGP)
% 
% In:
% 	gp	- the gamepad object
%	nGP	- the current number of gamepad objects
% 
% Out:
% 	gp	- the updated gamepad object
% 
% Updated: 2011-09-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if nGP==1
	clear JoyMEX;
end
JoyMEX('init',gp.padID);
