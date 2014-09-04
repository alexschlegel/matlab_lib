function Wait(sch,varargin)
% Group.Scheduler.Wait
% 
% Description:	execute tasks in the scheduler
% 
% Syntax:	sch.Wait([priority]=sch.PRIORITY_IDLE,[tEndMax]=Inf)
% 
% In:
%	priority	- execute tasks at or above this priority
%	tEndMax		- try to end no later than this time
%
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[priority,tEndMax]	= ParseArgs(varargin,sch.PRIORITY_IDLE,Inf);

p_Check(sch,priority,tEndMax);

WaitSecs(sch.root.info.scheduler.wait/1000);
