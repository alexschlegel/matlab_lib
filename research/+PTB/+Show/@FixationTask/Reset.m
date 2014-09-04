function Reset(ft)
% PTB.FixationTask.Reset
% 
% Description:	reset the fixation task results
% 
% Syntax:	ft.Reset
% 
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

PTBIFO.fixation_task.tShow		= [];
PTBIFO.fixation_task.tResponse	= [];
PTBIFO.fixation_task.tStop		= [];

if ft.Running
	PTBIFO.fixation_task.tGo	= PTB.Now;
	PTBIFO.fixation_task.tLast	= PTBIFO.fixation_task.tGo;
else
	PTBIFO.fixation_task.tGo	= [];
	PTBIFO.fixation_task.tLast	= [];
	
	ft.parent.Scheduler.Remove('fixation_task');
end

p_Stage0(ft);
