function [tStop,bShown,fPassed,bAbort,tShow,tResponse] = Stop(ft)
% PTB.FixationTask.Stop
% 
% Description:	stop the fixation task
% 
% Syntax:	[tStop,bShown,fPassed,bAbort,tShow,tResponse] = ft.Stop
%
% Out:
%	tStop		- the time the task stopped
%	bShown		- true if the fixation task was shown
%	fPassed		- the fraction of fixation tasks that were passed, or 1 if the
%				  fixation task has not been shown
%	bAbort		- true if the task was aborted
%	tShow		- an Nx1 array of the times at which the fixation task was shown
%	tResponse	- an Mx1 array of the times at which the subject responded
% 
% Updated: 2012-02-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if ft.Running
	ft.parent.Scheduler.Pause('fixation_task');
	
	PTBIFO.fixation_task.tStop	= PTB.Now;
	
	ft.AddLog('stopped');
	
	ft.parent.Window.SetStore(false);
	
	p_Stage0(ft);
end

tStop	= PTBIFO.fixation_task.tStop;

[bShown,fPassed,bAbort,tShow,tResponse]	= ft.Result([],[],false);
