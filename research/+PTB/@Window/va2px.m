function px = va2px(win,va)
% PTB.Window.va2px
% 
% Description:	convert degrees of visual angle to pixels
% 
% Syntax:	px = win.va2px(va)
% 
% In:
% 	va	- an array of degrees of visual angle
% 
% Out:
% 	px	- the equivalent measure in pixels
% 
% Updated: 2011-12-17
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

px	= 2*PTBIFO.window.distance.*PTBIFO.window.dpm.*tan(pi*va/360);
