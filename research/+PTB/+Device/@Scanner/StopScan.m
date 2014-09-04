function StopScan(scn,varargin)
% PTB.Scanner.StopScan
% 
% Description:	call after the scanner finishes
% 
% Syntax:	scn.StopScan([bPause]=false)
% 
% In:
%	[bPause]	- true to restart the scanner where it left off once StartScan
%				  is called again
%
% Updated: 2011-12-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bPause	= ParseArgs(varargin,false);

if notfalse(scn.parent.Info.Get('scanner','simulate'))
%we're simulating the scanner, shut down the timers
	try
		stop(scn.TKey);
		stop(scn.TSim);
	catch me
		scn.AddLog(['error stopping scan (' me.message ')']);
	end
end

scn.parent.Info.Set('scanner','reset',~bPause);

if ~bPause
%clear the scanner trigger buffer
	[d,t]	= scn.parent.Serial.Check(scn.SCANNER_TRIGGER);
%set the number of TRs heard to 0
	scn.parent.Info.Set('scanner',{'tr','heard'},0);
end

scn.parent.Info.Set('scanner','running',false);
scn.parent.Scheduler.Remove('scanner');
