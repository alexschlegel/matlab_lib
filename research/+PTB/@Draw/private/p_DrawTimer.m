function p_DrawTimer(drw,h,tTotal,tRemain)
% p_DrawTimer
% 
% Description:	draw the countdown timer
% 
% Syntax:	p_DrawTimer(drw,h,tTotal,tRemain)
% 
% In:
% 	drw		- the PTB.Draw object
%	h		- the window onto which to draw
%	tTotal	- the total amount of time
%	tRemain	- the remaining time
% 
% Updated: 2012-11-29
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
fRemain	= tRemain/tTotal;
a		= 360-360*fRemain;
col		= interp1([1;0.5;0],[0 255 0; 255 255 0; 255 0 0],fRemain,'linear');

rect	= [5 5 100 100];
Screen('FillOval',h,[0 0 0],rect);
Screen('FillArc',h,col,rect,a,360-a);
