function Remove(sch,strName)
% Group.Scheduler.Remove
% 
% Description:	remove tasks from the scheduler
% 
% Syntax:	sch.Remove(strName)
% 
% In:
%	strName	- the name of the task
%
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
p_GetRemoveLock(sch);

k	= p_Get(sch,strName);

if ~isempty(k) 
%mark the task for removal
	sch.root.info.scheduler.task(k).mode	= bitset(sch.root.info.scheduler.task(k).mode,sch.MODE_REMOVE);
end

p_ReleaseRemoveLock(sch);
