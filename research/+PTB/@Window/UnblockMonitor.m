function UnblockMonitor(win,varargin)
% PTB.Window.UnblockMonitor
% 
% Description:	close the blocking window on a previously blocked monitor
% 
% Syntax:	win.UnblockMonitor([kMonitor]=<all>)
% 
% In:
% 	[kMonitor]	- the monitor to unblock (start at 1)
% 
% Updated: 2012-11-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
kMonitor	= ParseArgs(varargin,[]);

hBlock	= win.parent.Info.Get('window','block');
nBlock	= numel(hBlock);

hAll	= Screen('Windows');

if isempty(kMonitor)
	kMonitor	= 1:nBlock;
end
nMonitor	= numel(kMonitor);

for kM=1:nMonitor
	kMCur	= kMonitor(kM);
	
	if any(hBlock(kMCur)==hAll)
		Screen('Close',hBlock(kMCur));
		
		hBlock(kMCur)	= 0;
	end
end

win.parent.Info.Set('window','block',hBlock);
