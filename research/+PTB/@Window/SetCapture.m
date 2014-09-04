function SetCapture(win,x,varargin)
% PTB.Window.SetCapture
% 
% Description:	set whether PTB.Window.Flip should capture the buffer contents
%				to an image file before flipping
% 
% Syntax:	win.SetStore(x,[rate]=<max>)
%
% In:
%	x		- the path to a directory to start capturing buffer images, or false
%			  to stop capturing
%	[rate]	- the maximum rate, in Hz, at which to capture
% 
% Updated: 2014-06-25
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

rate	= ParseArgs(varargin,[]);

PTBIFO.window.bcapture		= notfalse(x);

if PTBIFO.window.bcapture
	PTBIFO.window.capture_dir	= x;
	
	%create the directory if necessary
		if ~isdir(PTBIFO.window.capture_dir)
			CreateDirPath(PTBIFO.window.capture_dir);
		end
	
	%set the capture rate and last capture time
		PTBIFO.window.capture_rate	= rate;
		PTBIFO.window.capture_time	= 0;
	
	win.AddLog('capture started');
else
	PTBIFO.window.capture_dir	= false;
	
	win.AddLog('capture stopped');
end
