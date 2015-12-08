function sHistory = GetTaskHistory(obj,kTask)
% subject.difficultymatch.GetTaskHistory
% 
% Description:	get the history associated with the specified task
% 
% Syntax: sHistory = obj.GetTaskHistory(kTask)
% 
% In:
%	kTask	- the index of the task
% 
% Out:
%	sHistory	- a struct of arrays containing information about the task's
%				  probe history (all nProbe x 1):
%					d:	the difficulty of each probe
%					result:	the result of each probe (true or false)
% 
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sHistory	= restruct(obj.history([obj.history.task]==kTask));
