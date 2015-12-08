function sInfo = GetTaskInfo(obj,varargin)
% subject.difficultymatch.GetTaskInfo
% 
% Description:	get information about a task
% 
% Syntax: sInfo = obj.GetTaskInfo([kTask]=1,<options>)
% 
% In:
%	[kTask]	- the task index
%	<options>:
%		performance:	(<calculate>) manually specify a performance struct
%		history:		(<calculate>) manually specify a history struct
% 
% Out:
%	sInfo	- a struct of info about the task:
%				performance: a struct of info about the task performance (see
%					GetTaskPerformance)
%				history: a struct of info about the task history (see
%					GetTaskHistory)
%				task: the task index
% 
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[kTask,opt]	= ParseArgs(varargin,1,...
				'performance'	, []	, ...
				'history'		, []	  ...
				);

if isempty(opt.performance)
	opt.performance	= obj.GetTaskPerformance(kTask);
end
if isempty(opt.history)
	opt.history	= obj.GetTaskHistory(kTask);
end

sInfo	= struct(...
			'performance'	, opt.performance	, ...
			'history'		, opt.history		, ...
			'task'			, kTask				  ...
			);
