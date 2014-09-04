function Remove(sch,strName)
% PTB.Scheduler.Remove
% 
% Description:	remove tasks from the scheduler
% 
% Syntax:	sch.Remove(strName)
% 
% In:
%	strName	- the name of the task
%
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

p_GetRemoveLock(sch);

k	= p_Get(sch,strName);

if ~isempty(k) 
%mark the task for removal
	PTBIFO.scheduler.task(k).mode	= bitset(PTBIFO.scheduler.task(k).mode,sch.MODE_REMOVE);
end

p_ReleaseRemoveLock(sch);
