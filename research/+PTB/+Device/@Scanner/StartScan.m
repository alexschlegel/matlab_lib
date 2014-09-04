function StartScan(scn,varargin)
% PTB.Scanner.StartScan
% 
% Description:	call before the scanner starts
% 
% Syntax:	scn.StartScan([nTR]=Inf)
%
% In:
%	[nTR]	- the number of TRs to expect before the scan ends
% 
% Updated: 2012-02-14
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nTR	= ParseArgs(varargin,Inf);

scn.parent.Info.Set('scanner',{'tr','time'},[]);
scn.parent.Info.Set('scanner',{'tr','total'},nTR);

%clear the scanner trigger buffer
	[d,t]	= scn.parent.Serial.Check(scn.SCANNER_TRIGGER);

%was the scanner reset?
	bReset		= scn.parent.Info.Get('scanner','reset');

	if notfalse(bReset)
	%yes, set the number of TRs heard to 0
		scn.parent.Info.Set('scanner',{'tr','heard'},0);
	end

if notfalse(scn.parent.Info.Get('scanner','simulate'))
%we're simulating, start up the timers
	%[d,t]	= scn.parent.Serial.Check(scn.SCANNER_TRIGGER);
	
	p_StartSimTimers(scn);
end

scn.parent.Info.Set('scanner','running',true);
scn.parent.Info.Set('scanner','last',false);

if ~scn.parent.Scheduler.Exists('scanner')
	priority	= scn.parent.Scheduler.PRIORITY_IDLE;
	tInterval	= scn.parent.Info.Get('scanner',{'tr','per'})/4;
	scn.parent.Scheduler.Add(@() false*scn.TR(),100,'scanner',[],[],priority,tInterval);
end
