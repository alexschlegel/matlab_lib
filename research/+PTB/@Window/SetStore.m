function SetStore(win,bStore)
% PTB.Window.SetStore
% 
% Description:	set whether PTB.Window.Flip should store the buffer contents
%				before flipping.  Flip will only not store the buffer if the
%				number of SetStore calls with bStore==true received equals the
%				number of SetStore calls with bStore==false.
% 
% Syntax:	win.SetStore(bStore)
%
% In:
%	bStore	- true if the calling process needs flip to store the buffer, false
%			  if it no longer does
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

nAdd						= 2*bStore-1;
PTBIFO.window.nsetstore	= PTBIFO.window.nsetstore + nAdd;
