function b = Exists(sch,strName)
% PTB.Scheduler.Exists
% 
% Description:	test whether a task exists in the scheduler
% 
% Syntax:	b = sch.Exists(strName)
% 
% In:
%	strName	- the name or id of the task
%
% Out:
%	b	- true if the task exists
%
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

b	= ~isempty(p_Get(sch,strName)) || ismember(strName,PTBIFO.scheduler.queue.add(1,:));
