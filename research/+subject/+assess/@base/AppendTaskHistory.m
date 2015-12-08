function AppendTaskHistory(obj,kTask,d,result)
% subject.assess.base.AppendTaskHistory
% 
% Description:	append a probe result to the history
% 
% Syntax: obj.AppendTaskHistory(kTask,d,result)
% 
% In:
%	kTask	- the task index
%	d		- the probe difficulty
%	result	- the probe result
%
% Updated:	2015-12-04
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

sEstimate	= obj.GetTaskEstimate(kTask);

%add the most recent record
	obj.history(end+1)	= struct(...
							'task'		, kTask				, ...
							'd'			, d					, ...
							'result'	, result			, ...
							'ability'	, sEstimate.ability	, ...
							'slope'		, sEstimate.slope	, ...
							'lapse'		, sEstimate.lapse	, ...
							'rmse'		, sEstimate.rmse	, ...
							'r2'		, sEstimate.r2		  ...
							);
	
	%make sure we get N x 1
		if numel(obj.history)==2
			obj.history	= reshape(obj.history,2,1);
		end

%keep a record of the number of probes
	obj.nProbe(kTask)	= obj.nProbe(kTask) + 1;
