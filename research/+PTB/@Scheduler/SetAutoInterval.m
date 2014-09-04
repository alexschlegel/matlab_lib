function SetAutoInterval(sch,tInterval)
% PTB.Scheduler.SetAutoInterval
% 
% Description:	set the interval of the scheduler timer
% 
% Syntax:	sch.SetAutoInterval(tInterval)
%
% In:
%	tInterval	- the interval at which the task timer should run, in ms
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sch.parent.Info.Set('scheduler','autointerval',tInterval);

sch.Pause;
set(sch.TCheck,'Period',tInterval/1000);
sch.Resume;
