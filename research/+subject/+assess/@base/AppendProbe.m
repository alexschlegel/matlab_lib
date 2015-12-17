function sEstimate = AppendProbe(obj,kTask,d,result)
% subject.assess.base.AppendProbe
% 
% Description:	append a probe to the history
% 
% Syntax: sEstimate = obj.AppendProbe(kTask,d,result)
% 
% In:
%	kTask	- the index of the task that was probed
%	d		- the difficulty of the probe
%	result	- true if the subject was correct
%
% Out:
%	sEstimate	- the new estimate for the assessed task (see GetTaskEstimate)
% 
% Updated:	2015-12-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%update the estimate
	if obj.nProbe(kTask)>1
	%wait until we have probes at more than one difficulty
		sHistory		= obj.GetTaskHistory(kTask);
		sPerformance	= obj.GetTaskPerformance([sHistory.d; d], [sHistory.result; result]);
		
		s	= obj.GetTaskInfo(kTask,'history',sHistory,'performance',sPerformance);
		
		[ability,slope,lapse,s.estimate.rmse,s.estimate.r2]	= obj.EstimateAbility(s);
		
		%set the new estimate to the mean of the last 5 estimates
			nProbe	= obj.nProbe(kTask);
			kMean	= max(1,nProbe-3):nProbe;
			
			s.estimate.ability	= mean([sHistory.ability(kMean); ability]);
			s.estimate.slope		= mean([sHistory.slope(kMean); slope]);
			s.estimate.lapse		= mean([sHistory.lapse(kMean); lapse]);
		
		obj.SetTaskEstimate(kTask,s.estimate);
	else
		s.estimate	= obj.GetTaskEstimate(kTask);
	end

%update the history
	obj.AppendTaskHistory(kTask,d,result);

sEstimate	= s.estimate;
