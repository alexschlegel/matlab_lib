function Reset(drw,varargin)
% PTB.Draw.Reset
% 
% Description:	reset the object to its initial state and wipe the current
%				drawing
% 
% Syntax:	drw.Reset([bFlip]=true)
%
% In:
%	[bFlip]	- true to flip the screen
% 
% Updated: 2012-11-29
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bFlip	= ParseArgs(varargin,true);

%reset the drawing
	p_InitializeDrawing(drw,bFlip);
%reset the state
	[drw.running,drw.ran]	= deal(false);
%reset the pointer
	drw.parent.Pointer.Reset;
	drw.lastmode	= -1;
%reset the timer
	fEnd	= drw.parent.Info.Get('draw',{'f','end'});
	
	if isnumeric(fEnd)
		drw.timerleft	= fEnd;
	end
