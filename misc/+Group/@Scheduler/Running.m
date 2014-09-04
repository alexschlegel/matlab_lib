function b = Running(sch,varargin)
% Group.Scheduler.Running
% 
% Description:	test if a task or the scheduler timer is running
% 
% Syntax:	b = sch.Running([strName])
%
% In:
%	[strName]	- the name of the task.  if unspecified, tests if the scheduler
%				  timer is running
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if nargin<2
	b	= notfalse(sch.Info.Get('running'));
else
	k	= p_Get(sch,varargin{1});
	
	vCompare	= sum(bitset(0,[sch.MODE_FINISHED sch.MODE_ABORTED sch.MODE_PAUSED sch.MODE_REMOVE]));
	b			= ~isempty(k) && bitand([sch.root.info.scheduler.task(k).mode],vCompare)==0;
end
