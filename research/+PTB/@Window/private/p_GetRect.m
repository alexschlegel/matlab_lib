function [rect,kScreen] = p_GetRect(kMonitor,pWindow,sWindow)
% p_GetRect
% 
% Description:	get the rect of a window with the specified parameters
% 
% Syntax:	rect = p_GetRect(kMonitor,pWindow,sWindow)
% 
% In:
% 	kMonitor	- the index of the monitor on which to open the window
%	pWindow		- the left-top position of the window on the monitor, or true
%				  for full screen
%	sWindow		- the width/height of the window, or true for full screen
% 
% Out:
% 	rect	- the rect of the window, or [] if full screen
%	kScreen	- the screen number of the window
% 
% Updated: 2012-12-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[nMonitor,resMonitor,pMonitor]	= GetMonitorInfo;
%nScreen							= p_NumScreens;

s		= Screen('Screens');
nScreen	= numel(s);

if nScreen>=nMonitor
	if nScreen>nMonitor
		kScreen	= conditional(nMonitor>1,kMonitor,0);
	else
		kScreens	= Screen('Screens');
		kScreen		= kScreens(kMonitor);
	end
	
	if isequal(sWindow,true)
	%full screen
		if isequal(pWindow,true)
			rect	= [];
		else
			rect	= [pWindow resMonitor(kMonitor,:)];
		end
	else
	%windowed
		%warning('Check this line!');%***I don't know if this is correct or if the positions should be absolute (in the monitor array)
		rect	= [pWindow pWindow+sWindow];
	end
else
%something funky, like unix with multiple monitors on one X screen
	kScreen	= 0;
	
	p		= pMonitor(kMonitor,:);
	s		= resMonitor(kMonitor,:);
	
	if isequal(sWindow,true)
	%full screen
		rect	= [p p+s];
	else
	%windowed
		pWindow	= pWindow + p;
		
		rect	= [pWindow pWindow+sWindow];
	end
end
