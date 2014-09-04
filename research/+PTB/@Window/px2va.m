function va = px2va(win,px)
% PTB.Window.px2va
% 
% Description:	convert pixels to degrees of visual angle
% 
% Syntax:	va = win.px2va(px)
% 
% In:
% 	px	- an array of pixel sizes
% 
% Out:
% 	va	- the equivalent measure in degrees of visual angle
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

va	= 360*atan(px./(2.*PTBIFO.window.distance.*PTBIFO.window.dpm))/pi;
