function p_Stage1(ft)
% p_Stage1
% 
% Description:	go to stage 1 of the fixation task, in which we show the fixation
%				task color, start checking for input, and wait to return the
%				fixation task to normal
% 
% Syntax:	p_Stage1(ft)
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

PTBIFO.fixation_task.stage	= 1;

%set the fixation dot to the task color
	PTBIFO.fixation_task.oldcolor	= PTBIFO.color.fixation;
	
	ft.parent.Color.Set('fixation','fixation_task');
%show it
	PTBIFO.fixation_task.tStart	= p_ShowTask(ft);
	PTBIFO.fixation_task.tShow		= [PTBIFO.fixation_task.tShow; PTBIFO.fixation_task.tStart];
	
	ft.AddLog('probe on',PTBIFO.fixation_task.tStart);
