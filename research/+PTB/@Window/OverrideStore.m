function OverrideStore(win,bStore)
% PTB.Window.OverrideStore
% 
% Description:	override the SetStore setting for the following flip
% 
% Syntax:	win.OverrideStore(bStore)
%
% In:
%	bStore	- true if flip should store the next buffer, false otherwise
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

PTBIFO.window.overridestore	= bStore;
