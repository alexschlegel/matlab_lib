function p_Stage2(ft)
% p_Stage2
% 
% Description:	go to stage 2 of the fixation task, in which we set the fixation
%				task back to normal and keep checking for input
% 
% Syntax:	p_Stage2(ft)
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

PTBIFO.fixation_task.stage	= 2;

%set the fixation color back to normal
	if ~isempty(PTBIFO.fixation_task.oldcolor)
		ft.parent.Color.Set('fixation',PTBIFO.fixation_task.oldcolor);
		
		PTBIFO.fixation_task.oldcolor	= [];
		
		tShow	= p_ShowTask(ft);
		
		ft.AddLog('probe off',tShow);
	end
