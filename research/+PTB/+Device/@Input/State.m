function [b,t] = State(inp)
% PTB.Device.Input.State
% 
% Description:	default State function for PTB.Device.Input objects.  this
%				should be customized for each input device.
% 
% Syntax:	[b,t] = inp.State
% 
% Out:
%	b	- an Nx1 logical array indicating which input elements are activated
%		  (i.e. which buttons are down)
%	t	- the time associated with the query
%
% Updated: 2011-12-15
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

t	= PTB.Now;
b	= false(255,1) & ~PTBIFO.input.(inp.type).basestate;
