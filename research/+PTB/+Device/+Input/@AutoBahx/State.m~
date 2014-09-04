function [b,t] = State(joy)
% PTB.Device.Input.Joystick.State
% 
% Description:	get the current state of the joystick
% 
% Syntax:	[b,t] = joy.State
% 
% Out:
%	b	- a 19x1 array indicating which buttons are down
%	t	- the time associated with the query
%
% Updated: 2012-01-30
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

t	= PTB.Now;

[sAxes,bButton]	= joyinput('MLRead',joy.joy);

b	= [reshape(bButton,11,1); reshape(sAxes,8,1)];

if ~isequal(PTBIFO.input.joystick.basestate,false)
	b(1:11)		= b(1:11) & ~PTBIFO.input.joystick.basestate(1:11);
	b(12:19)	= b(12:19) - PTBIFO.input.joystick.basestate(12:19);
end
