function [b,t] = State(key)
% PTB.Device.Input.Keyboard.State
% 
% Description:	get the current state of the keyboard
% 
% Syntax:	[b,t] = key.State
% 
% Out:
%	b	- a 255x1 logical array indicating which keys are down
%	t	- the time associated with the query
%
% Updated: 2012-04-29
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent bugfix;

global PTBIFO;

if isempty(bugfix)
	bugfix	= isequal(computername,'naraka-ubuntu');
end


[dummy,tGS,bState]	= KbCheck;
bState				= bState(1:255);

if bugfix
	bState	= [0 bState(1:end-1)];
end

t	= getsecs2ms(tGS);
b	= bState & ~PTBIFO.input.keyboard.basestate;
