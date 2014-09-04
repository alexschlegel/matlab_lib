function varargout = Flip(win,varargin)
% PTB.Window.Flip
% 
% Description:	flip the main window
% 
% Syntax:	t = win.Flip([strInfo]=<nothing>)
% 
% In:
%	[strInfo]	- info about the flip
%
% Out:
%	t	- the time of the flip
%
% Side-effects:	adds a log entry if information was supplied about the flip
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

%should we store the current state before flipping?
	if ~isempty(PTBIFO.window.overridestore)
		if PTBIFO.window.overridestore
			win.Store;
		end
		PTBIFO.window.overridestore	= [];
	elseif PTBIFO.window.nsetstore>0
		win.Store;
	end

tGS	= Screen('Flip',PTBIFO.window.h.main);

PTBIFO.window.flips	= PTBIFO.window.flips + 1;

if nargout>0 || nargin>1 
	varargout{1}	= getsecs2ms(tGS);
	
	if nargin>1 && ~isempty(varargin{1})
		win.parent.Log.Append('flip',varargin{1},varargout{1});
	end
end

%should we capture the window to an image file?
	if PTBIFO.window.bcapture
		tNow	= getsecs2ms(tGS);
		
		if isempty(PTBIFO.window.capture_rate) || (tNow >= PTBIFO.window.capture_time + PTBIFO.window.capture_rate)
			PTBIFO.window.capture_time	= tNow;
			
			win.Capture(PTBIFO.window.capture_dir);
		end
	end
