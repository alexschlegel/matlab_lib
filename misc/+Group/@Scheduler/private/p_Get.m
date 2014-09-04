function k = p_Get(sch,strName)
% p_Get
% 
% Description:	get the index of a task by name
% 
% Syntax:	k = p_Get(sch,strName)
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ischar(strName)
%task name passed
	[b,k]	= ismember(strName,{sch.root.info.scheduler.task.name});
	
	if ~b
		k	= [];
	end
elseif strName>=1 && strName<=numel(sch.root.info.scheduler.task)
%task index passed
	k	= strName;
else
%nothin'
	k	= [];
end
