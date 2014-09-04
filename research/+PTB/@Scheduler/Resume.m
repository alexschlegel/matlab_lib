function Resume(sch,varargin)
% PTB.Scheduler.Resume
% 
% Description:	resume a task or the scheduler timer
% 
% Syntax:	sch.Resume([strName])
%
% In:
%	[strName]	- the name of the task.  if unspecified, resumes the scheduler
%				  timer
% 
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if nargin<2
%resume the timer
	sch.parent.Info.Set('scheduler','running',true);
	
	if ~IsTimerRunning(sch.TCheck)
		start(sch.TCheck);
	end
else
%resume a task
	k	= p_Get(sch,varargin{1});
	
	if ~isempty(k)
		PTBIFO.scheduler.task(k).mode	= bitset(PTBIFO.scheduler.task(k).mode,sch.MODE_PAUSED,0);
	end
end
