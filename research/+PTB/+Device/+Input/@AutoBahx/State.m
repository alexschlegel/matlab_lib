function [b,t] = State(ab)
% PTB.Device.Input.AutoBahx.State
% 
% Description:	get the current state of the AutoBahx
% 
% Syntax:	[b,t] = ab.State
% 
% Out:
%	b	- a logical indicating whether the button is down
%	t	- the time associated with the query
%
% Updated: 2012-03-23
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

t			= PTB.Now;
[tDown,tUp]	= ab.GetTimes;

if ~isempty(tDown)
%button down since last call
	if ~isempty(tUp)
	%button down & up since last call
		tD	= max(tDown);
		tU	= max(tUp);
		b	= tD >= tU;
		
		if b
			if PTBIFO.input.autobahx.basestate
				b	= false;
			else
				t	= tD;
			end
		else
			t	= tU;
		end
	else
	%only button down since last call
		b	= ~PTBIFO.input.autobahx.basestate;
		t	= max(tDown);
	end
elseif ~isempty(tUp)
%only button up since last call
	b	= false;
	t	= max(tUp);
else
%no buttons since last call
	b	= PTBIFO.input.autobahx.last;
end

PTBIFO.input.autobahx.last	= b;
