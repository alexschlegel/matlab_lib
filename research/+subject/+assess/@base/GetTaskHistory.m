function sHistory = GetTaskHistory(obj,varargin)
% subject.assess.base.GetTaskHistory
% 
% Description:	get the history associated with the specified task
% 
% Syntax: sHistory = obj.GetTaskHistory([kTask]=1)
% 
% In:
%	[kTask]	- the index of the task
% 
% Out:
%	sHistory	- a struct of arrays containing information about the task's
%				  probe history (all nProbe x 1):
%					d:	the difficulty of each probe
%					result:	the result of each probe (true or false)
%					ability:	the ability estimate after each probe
%					slope:	the slope estimate after each probe
%					lapse:	the lapse estimate after each probe
%					rmse:	the root mean square error of the estimate after
%						each probe
%					r2:	the r^2 of the estimate after each probe
% 
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
kTask	= ParseArgs(varargin,1);

sHistory	= restruct(obj.history([obj.history.task]==kTask));

if isempty(sHistory)
	cField		= fieldnames(sHistory);
	sHistory	= dealstruct(cField{:},[]);
end