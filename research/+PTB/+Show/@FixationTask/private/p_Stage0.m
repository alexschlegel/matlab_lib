function p_Stage0(ft)
% p_Stage0
% 
% Description:	go to stage 0 of the fixation task, in which we end the task and
%				reset everything
% 
% Syntax:	p_Stage0(ft)
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

PTBIFO.fixation_task.stage	= 0;

%set the fixation color back to normal
	if ~isempty(PTBIFO.fixation_task.oldcolor)
		ft.parent.Color.Set('fixation',PTBIFO.fixation_task.oldcolor);
		
		PTBIFO.fixation_task.oldcolor	= [];
		
		p_ShowTask(ft);
	else
		ft.AddLog('probe reset');
	end
