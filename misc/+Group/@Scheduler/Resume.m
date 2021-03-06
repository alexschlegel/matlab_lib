function Resume(sch,varargin)
% Group.Scheduler.Resume
% 
% Description:	resume a task or the scheduler timer
% 
% Syntax:	sch.Resume([strName])
%
% In:
%	[strName]	- the name of the task.  if unspecified, resumes the scheduler
%				  timer
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if nargin<2
%resume the timer
	sch.Info.Set('running',true);
	
	if ~IsTimerRunning(sch.TCheck)
		start(sch.TCheck);
	end
else
%resume a task
	k	= p_Get(sch,varargin{1});
	
	if ~isempty(k)
		sch.root.info.scheduler.task(k).mode	= bitset(sch.root.info.scheduler.task(k).mode,sch.MODE_PAUSED,0);
	end
end
