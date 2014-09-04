function sz = p_GetWindowSize(drw)
% p_GetWindowSize
% 
% Description:	get the size of the window, in pixels
% 
% Syntax:	sz = p_GetWindowSize(drw)
% 
% Updated: 2012-11-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO

rWin	= PTBIFO.window.rect.main;
sz		= rWin(3:4) - rWin(1:2);
