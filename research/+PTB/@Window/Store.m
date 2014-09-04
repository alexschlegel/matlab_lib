function Store(win)
% PTB.Window.Store
% 
% Description:	store the current main window contents to the hidden copy
% 
% Syntax:	win.Store
% 
% Updated: 2011-12-14
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

h	= PTBIFO.window.h;
Screen('CopyWindow',h.main,h.copy);
