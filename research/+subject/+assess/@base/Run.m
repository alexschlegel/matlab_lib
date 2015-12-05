function sEstimate = Run(obj,varargin)
% subject.assess.base.Run
% 
% Description:	run the assessment
% 
% Syntax: sEstimate = obj.Run(<options>)
% 
% In:
%	<options>:
%		param:	(struct) either a struct of parameters to pass to the task
%				function, or a function that takes three inputs:
%					kTask		- the task index
%					kProbe		- the probe number for the current task
%					kProbeTotal	- the probe number over all tasks
%				and returns a parameter struct
%		min:	(25) the minimum number of steps per task
%		max:	(100) the maximum number of steps per task
%		rmse:	([]) stop assessing a task if the rmse falls to at or below this
%				level
%		r2:		([]) stop assessing a task if the r^2 rises to at or above this
%				level
%		silent:	(true) true to suppress status output
%
% Out:
%	sEstimate	- a struct describing the ability estimate for each task. each
%				  field is nTask x 1.
% 
% Updated:	2015-12-04
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'param'		, []	, ...
			'min'		, 25	, ...
			'max'		, 100	, ...
			'rmse'		, []	, ...
			'r2'		, []	, ...
			'silent'	, true	  ...
	);

bCheckRMSE	= ~isempty(opt.rmse);
bCheckR2	= ~isempty(opt.r2);

nTask		= numel(obj.f);
nProbeTotal	= nTask*opt.max;

lenProbe	= numel(num2str(opt.max));
lenTask		= numel(num2str(nTask));

progress('action','init','label','running assessment','total',nProbeTotal,'silent',opt.silent);
for kS=1:nProbeTotal
	[est,kTask,d,result]	= obj.Step('param',opt.param,'max',opt.max);
	
	if isnan(kTask)
	%must be finished
		progress('action','end');
		break;
	end
	
	kProbe	= obj.nProbe(kTask);
	
	if (kProbe>=opt.min) && ((bCheckRMSE && est.rmse<=opt.rmse) || (bCheckR2 && est.r2<=opt.r2))
	%mark this task as finished
		obj.nProbe(kTask)	= inf;
	end
	
	progress;
	
	if ~opt.silent
		if nTask>1
			strTask	= ['task: %' num2str(lenTask) 'd | '];
			argTask	= {kTask};
		else
			strTask	= '';
			argTask	= {};
		end
		
		strProbe	= ['probe: %' num2str(lenProbe) 'd | '];
		fprintf([strTask	strProbe	'd: %.3f | result: %d | ability: %.3f | slope: %6.3f | lapse: %.3f | rmse: %.3f | r^2: %.3f\n'],...
				 argTask{:},kProbe,		 d,		   result,		est.ability,	est.slope,	   est.lapse,	 est.rmse,	  est.r2);
	end
end

%get the final estimates
	sEstimate	= arrayfun(@obj.GetTaskEstimate,(1:nTask)');
	sEstimate	= restruct(sEstimate);
