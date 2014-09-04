function [kMonitor,pWindow,sWindow] = p_GuessWindow(varargin)
% p_GuessWindow
% 
% Description:	guess the window parameters
% 
% Syntax:	[kMonitor,pWindow,sWindow] = p_GuessWindow([bFull]=<auto>)
% 
% In:
%	[bFull]	- true if the window should be opened full screen
% 
% Out:
% 	kMonitor	- the index of the monitor on which to open the window
%	pWindow		- the left-top position of the window, or true for full screen
%	sWindow		- the width/height of the window, or true for full screen
% 
% Updated: 2011-12-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bFull	= ParseArgs(varargin,[]);

[nMonitor,resMonitor,pMonitor]	= GetMonitorInfo;

if nMonitor>1
%we have multiple correctly-identified monitors
	kMonitor	= nMonitor;
	
	if notfalse(bFull) || isempty(bFull)
		pWindow		= true;
		sWindow		= true;
	else
		offset	= [10 32];
		
		pWindow	= pMonitor(end,:) + offset;
		sWindow	= round(resMonitor(end,:)/2) - offset;
	end
else
%just one monitor
	kMonitor	= 1;
	
	if bFull
		pWindow	= true;
		sWindow	= true;
	else
		offset	= [10 32];
		pWindow	= pMonitor + offset;
		sWindow	= round(resMonitor/2) - offset;
	end
end
