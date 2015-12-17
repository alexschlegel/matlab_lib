function sInfo = GetTaskInfo(obj,varargin)
% subject.assess.base.GetTaskInfo
% 
% Description:	get information about the tasks
% 
% Syntax: sInfo = obj.GetTaskInfo([kTask]=<all>,<options>)
% 
% In:
%	[kTask]	- an array of task numbers
%	<options>:
%		performance:	(<calculate>) manually specify a performance struct
%		estimate:		(<calculate>) manually specify an estimate struct
%		history:		(<calculate>) manually specify a history struct
% 
% Out:
%	sInfo	- a struct of info about the tasks:
%				performance: a struct of info about the task performance (see
%					GetTaskPerformance)
%				estimate: a struct of info about the current ability estimate
%					(see GetTaskEstimate)
%				history: a struct of info about the task history (see
%					GetTaskHistory)
%				task: the task index
% 
% Updated:	2015-12-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	[kTask,opt]	= ParseArgs(varargin,[],...
					'performance'	, []	, ...
					'estimate'		, []	, ...
					'history'		, []	  ...
					);
	
	if isempty(kTask)
		kTask	= (1:numel(obj.f))';
	end

sInfo	= arrayfun(@GetTaskInfoSingle,kTask);

if numel(kTask)>1
	sInfo	= restruct(sInfo);
end

%-------------------------------------------------------------------------------
function s = GetTaskInfoSingle(k)
	%get the history
		if isempty(opt.history)
			sHistory	= obj.GetTaskHistory(k);
		else
			sHistory	= opt.history;
		end
	
	%get the performance
		if isempty(opt.performance)
			sPerformance	= obj.GetTaskPerformance(sHistory.d,sHistory.result);
		else
			sPerformance	= opt.performance;
		end
	
	%get the estimate
		if isempty(opt.estimate)
			sEstimate	= obj.GetTaskEstimate(k);
		else
			sEstimate	= opt.estimate;
		end

	s	= struct(...
			'performance'	, sPerformance	, ...
			'estimate'		, sEstimate		, ...
			'history'		, sHistory		, ...
			'task'			, k				  ...
			);
end
%-------------------------------------------------------------------------------

end
