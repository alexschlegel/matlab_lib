function [x,t] = State(poi)
% PTB.Device.Pointer.State
% 
% Description:	get the current state of the pointer
% 
% Syntax:	[x,t] = poi.State
% 
% Out:
%	x	- an 7x1 array indicating the following states:
% 			x position (0->1)
% 			y position (0->1)
% 			pressure (0->1)
% 			x tilt (-1->1)
% 			y tilt (-1->1)
%			draw button
%			erase button
%	t	- the time associated with the query
%
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

t	= PTB.Now;

if t>=poi.tNextState
	x	= poi.GetPointer;
	
	if PTBIFO.pointer.swap.xy
		x([poi.IDX_XPOS poi.IDX_YPOS])		= x([poi.IDX_YPOS poi.IDX_XPOS]);
		x([poi.IDX_XTILT poi.IDX_YTILT])	= x([poi.IDX_YTILT poi.IDX_XTILT]);
	end
	if PTBIFO.pointer.swap.lr
		x(poi.IDX_XPOS)		= 1 - x(poi.IDX_XPOS);
		x(poi.IDX_XTILT)	= -x(poi.IDX_XTILT);
	end
	if PTBIFO.pointer.swap.ud
		x(poi.IDX_YPOS)		= 1 - x(poi.IDX_YPOS);
		x(poi.IDX_YTILT)	= -x(poi.IDX_YTILT);
	end
	
	poi.lastState	= x;
	
	poi.tNextState	= t + 1000/PTBIFO.pointer.rate;
else
	x	= poi.lastState;
end
