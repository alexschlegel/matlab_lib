function [sEstimate,kTask,d,result] = Step(obj,varargin)
% subject.assess.base.Step
% 
% Description:	run one step of the assessment
% 
% Syntax: [sEstimate,kTask,d,result] = obj.Step(<options>)
%
% In:
%	<options>:
%		param:	(struct) either a struct of parameters to pass to the task
%				function, or a function that takes three inputs:
%					kTask		- the task index
%					kProbe		- the probe number for the current task
%					kProbeTotal	- the probe number over all tasks
%				and returns a parameter struct
%		task:	(<auto>) the index of the task to probe
%		max:	(inf) the maximum number of probes to execute per task
%
% Out:
%	sEstimate	- the new estimate for the assessed task (see GetTaskEstimate),
%				  or [] if no task was assessed
%	kTask		- the index of the task that was assessed, or NaN if no task was
%				  assessed
%	d			- the probed difficulty level
%	result		- the result of the probe
% 
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'param'	, struct	, ...
		'task'	, []		, ...
		'max'	, inf		  ...
		);

sEstimate			= [];
[kTask,d,result]	= deal(NaN);

%get the next task
	sTask	= obj.GetNextTask('task',opt.task,'max',opt.max);
	
	if isempty(sTask)
	%must be finished
		return;
	end
	
	kTask	= sTask.kTask;

%construct the parameter struct
	%defaults
		nTask			= numel(obj.f);
		sEstimateAll	= arrayfun(@(k) obj.GetTaskEstimate(k),(1:nTask)');
		
		sParam	= struct(...
					'kProbe'		, sTask.kProbe		, ...
					'kProbeTotal'	, sTask.kProbeTotal	, ...
					'estimate'		, sEstimateAll		  ...
					);
	%user specified
		switch class(opt.param)
			case 'struct'
			case 'function_handle'
				nArg	= nargin(opt.param);
				assert(nArg==3 || nArg<0,'param function must take three arguments');
				
				opt.param	= opt.param(kTask,sTask.kProbe,sTask.kProbeTotal);
			otherwise
				error('invalid param option');
		end
		
		cField	= fieldnames(opt.param);
		nField	= numel(cField);
		
		for kF=1:nField
			sParam.(cField{kF})	= opt.param.(cField{kF});
		end

%probe the subject
	d		= sTask.d;
	result	= sTask.f(d,sParam);

%append the probe to the history
	sEstimate	= obj.AppendProbe(kTask,d,result);
