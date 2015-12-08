function sTask = GetNextTask(obj,varargin)
% subject.assess.base.GetNextTask
% 
% Description:	get a struct describing the next task to probe
% 
% Syntax: sTask = obj.GetNextTask(<options>)
%
% In:
%	<options>:
%		task:	(<auto>) the index of the task to probe
%		max:	(inf) the maximum number of probes to execute per task
% 
% Out:
%	sTask	- a struct containing information needed to run the next probe
% 
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'task'	, []	, ...
		'max'	, inf	  ...
		);

sTask	= [];

%get the next task number
	if isempty(opt.task)
		nTask		= numel(obj.f);
		
		%generate a new task sequence if necessary
			if all(obj.taskSequence==0)
				obj.taskSequence	= randperm(nTask);
				
				%keep only the tasks that haven't yet been assessed to completion
					bInvalid	= obj.nProbe(obj.taskSequence)>=opt.max;
					
					obj.taskSequence(bInvalid)	= 0;
				
				%quit if we are finished
					if all(obj.taskSequence==0)
						return;
					end
			end
		
		%get the next task
			kTaskIndex	= find(obj.taskSequence~=0,1);
			kTask		= obj.taskSequence(kTaskIndex);
		
		%remove the task from the sequence
			obj.taskSequence(kTaskIndex)	= 0;
	else
		kTask	= opt.task;
	end

%get the next probe value
	s	= obj.GetTaskInfo(kTask);
	
	if obj.nProbe(kTask)==0
		d	= s.estimate.ability;
	else
		d	= obj.GetNextProbe(s);
	end
	
	%find the closest allowed d value
		dDiff	= abs(d - obj.d);
		kClose	= find(dDiff==min(dDiff),1);
		d		= obj.d(kClose);

%construct the task info
	nProbeTotal	= sum(obj.nProbe);
	
	sTask	= struct(...
				'kTask'			, kTask					, ...
				'kProbe'		, obj.nProbe(kTask)+1	, ...
				'kProbeTotal'	, nProbeTotal+1			, ...
				'f'				, obj.f{kTask}			, ...
				'd'				, d						  ...
				);
