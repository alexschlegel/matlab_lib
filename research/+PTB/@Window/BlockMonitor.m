function hBlock = BlockMonitor(win,varargin)
% PTB.Window.BlockMonitor
% 
% Description:	open a semi-transparent screen over a monitor.  useful for
%				preventing subjects from affecting the computer.
% 
% Syntax:	hBlock = win.BlockMonitor([kMonitor]=<default>,<options>)
% 
% In:
% 	[kMonitor]	- the monitor to block (start at 1)
%	<options>:
%		alpha:	(0.5) the transparency of the blocking window
% 
% Out:
% 	hBlock	- the handle to the blocking window
% 
% Updated: 2012-12-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[kMonitor,opt]	= ParseArgs(varargin,[],...
					'alpha'	, 0.5	  ...
					);

if isempty(kMonitor)
	kMonitor	= win.parent.Info.Get('window','block_default');
end

if kMonitor==0
	return;
end

%is the monitor already blocked?
	hBlock	= win.parent.Info.Get('window','block');
	nBlock	= numel(hBlock);
	
	if nBlock>=kMonitor && any(Screen('Windows')==hBlock(kMonitor))
		hBlock	= hBlock(kMonitor);
		return;
	end
%block the monitor
	[rect,kScreen]	= p_GetRect(kMonitor,[0 0],true);
	rect(4)			= rect(4)-1;						%make sure Psychtoolbox doesn't use fullscreen mode (prevents transparenty on kohler)
	
	PsychDebugWindowConfiguration(1,opt.alpha);
		hBlock(kMonitor)	= Screen('OpenWindow',kScreen,[],rect);
		
		win.parent.Show.Color('red','window',hBlock(kMonitor));
		win.parent.Show.Line('black',[-10 -10],[10 10],1,'window',hBlock(kMonitor));
		win.parent.Show.Line('black',[10 -10],[-10 10],1,'window',hBlock(kMonitor));
		
		Screen('Flip',hBlock(kMonitor));
	PsychDebugWindowConfiguration(-1);
%remember the handles
	win.parent.Info.Set('window','block',hBlock);
