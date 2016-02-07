classdef base < handle
% subject.assess.base
% 
% Description:	base class for assessing subject performance on a set of tasks
% 
% Syntax: obj = subject.assess.base(f,<options>)
%
% In:
%	f	- the value of the <f> property
%	<options>:
%		estimate:	(0.5) an initial estimate of the <ability> property
%		target:		(0.75) the value of the <target> property
%		chance:		(0.5) the value of the <chance> property
%		lapse:		(0.03) the initial estimate of the <lapse> property
%		d:			(0:0.05:1) the value of the <d> property
%		d_hist:		([]) an array specifying the difficulties of a set of probes
%					that have already been administered
%		res_hist:	([]) an array the same size as <d_hist> specifying the
%					results of the probes (true/false)
%		task_hist:	([]) an array the same size as <d_hist> specifying the index
%					of the task administered in each probe. must be specified
%					only if multiple tasks are defined (see <f>).
% 
% Methods:
%	GetTaskInfo:		get information about the tasks
%	Plot:				plot a task's assessment results
%	Run:				run a full assessment
%	SimulateProbe:		simulate a subject response
%	Step:				run one step of the assessment
% 
% Properties:
%	f:	(r) the handle to a function that takes a difficulty value from 0 to 1
%		(0==easiest) and a parameter struct as an input, presents the subject
%		with a task at the specified difficulty, and returns true if the subject
%		was correct, or false if the subject was incorrect. can also be a cell
%		of handles to such functions if multiple tasks (e.g. multiple
%		conditions) should be assessed simultaneously. in this case, probes will
%		alternate randomly between the tasks. the SimulateProbe class method can
%		be used here to simulate an assessment. the parameter struct consists of
%		fields added manually during the call to the Step or Run methods, and
%		additionally the following fields:
%			kProbe:		the probe number for the task
%			kProbTotal:	the probe number over all tasks
%			estimate:	a struct array specifying the current estimate for each
%						task (see GetTaskEstimate). e.g.
%						param.estimate(3).ability is the current estimate of the
%						subject's ability on the 3rd task.
%	ability:	(r) the current estimate of the difficulty value at which the
%		subject will perform according to the target, or an array of ability
%		estimates for multiple tasks (see <f>)
%	slope:	(r) the current estimate of the slope of the subject's psychometric
%		curve, or an array of slopes for multiple tasks (see <f>)
%	target:	(r) the target subject performance, as a fraction of tasks correct
%	chance:	(r) the chance level of subject performance (0->1)
%	lapse:	(r) the current estimate of subject's lapse rate (0->1), or an array
%		of lapse rates
%	d:	(r) allowed values of d
%	rmse:	(r) the root mean square error between the fit and the data, or an
%		array of rmses
%	r2:	(r) the degree of freedom adjusted r^2 between the fit and the data, or
%		an array of r^2s
%	history:	(r) a struct recording the performance history and ability
%		estimates
%
% Example:
%	simAbility = [0.2; 0.4; 0.6];
%	chance = 0.25;
%	f = arrayfun(@(a) @(d,param) subject.assess.base.SimulateProbe(d,param,'ability',a,'chance',chance),simAbility,'uni',false);
%	a = subject.assess.base(f,'chance',chance);
%	sEstimate = a.Run('max',50,'rmse',0.2,'silent',false);
%	h = a.Plot(1);
% 
% Updated:	2016-02-06
% Copyright 2016 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%READ-ONLY
		properties (SetAccess=protected, GetAccess=public)
			f			= [];
			ability		= NaN;
			slope		= 5;
			target		= NaN;
			chance		= NaN;
			lapse		= NaN;
			d			= [];
			rmse		= NaN;
			r2			= NaN;
			history		= struct;
		end
	
	%PRIVATE
		properties (SetAccess=protected, GetAccess=protected)
			taskSequence 	= [];
			nProbe			= [];
		end
%/PROPERTIES--------------------------------------------------------------------

%PROPERTY GET/SET---------------------------------------------------------------
	methods
		function x = get.target(obj)
			x	= obj.target;
		end
		function obj = set.target(obj,x)
			obj.target	= x;
		end
	end
%/PROPERTY GET/SET--------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = base(f,varargin)
				obj = obj@handle();
				
				opt	= ParseArgs(varargin,...
						'estimate'	, 0.5 		, ...
						'target'	, 0.75		, ...
						'chance'	, 0.5		, ...
						'lapse'		, 0.03		, ...
						'd'			, 0:0.05:1	, ...
						'd_hist'	, []		, ...
						'res_hist'	, []		, ...
						'task_hist'	, []		  ...
						);
				
				f		= reshape(ForceCell(f),[],1);
				nTask	= numel(f);
				
				obj.f		= f;
				obj.target	= opt.target;
				obj.chance	= opt.chance;
				obj.d		= sort(reshape(opt.d,[],1));
				
				obj.ability	= repto(opt.estimate,[nTask 1]);
				obj.slope	= repto(obj.slope,[nTask 1]);
				obj.lapse	= repto(opt.lapse,[nTask 1]);
				
				obj.rmse	= repto(obj.rmse,[nTask 1]);
				obj.r2		= repto(obj.r2,[nTask 1]);
				
				obj.history		= repmat(dealstruct('task','d','result','ability','slope','lapse','rmse','r2',[]),[0 0]);
				
				obj.nProbe			= zeros(nTask,1);
				obj.taskSequence	= zeros(nTask,1);
				
				%child-class-specific initialization
					obj.init(varargin{:});
				
				%add the manual history if specified
					if ~isempty(opt.d_hist)
						nHist	= numel(opt.d_hist);
						
						%error checking
							assert(numel(opt.res_hist)==nHist,'<d_hist> and <res_hist> options must have the same number of elements');
							
							if nTask==1 && isempty(opt.task_hist)
								opt.task_hist	= ones(size(opt.d_hist));
							else
								assert(numel(opt.task_hist)==nHist,'<d_hist> and <task_hist> options must have the same number of elements');
							end
						
						%add the probes
							for kH=1:nHist
								kTask	= opt.task_hist(kH);
								d		= opt.d_hist(kH);
								result	= opt.res_hist(kH);
								
								obj.AppendProbe(kTask,d,result);
							end
					end
			end
		end
	
	%STATIC
		methods (Access=public, Static)
			b = SimulateProbe(d,varargin)
			[ability,slope,lapse,rmse,r2] = EstimateAbility(s);
		end
	
	%PRIVATE
		methods (Access=protected)
			sEstimate		= AppendProbe(obj,kTask,d,result);
							  AppendTaskHistory(obj,kTask,d,result);
			d				= GetNextProbe(obj,s);
			sTask			= GetNextTask(obj,varargin);
			sEstimate		= GetTaskEstimate(obj,varargin);
			sHistory		= GetTaskHistory(obj,varargin);
			sPerformance	= GetTaskPerformance(obj,varargin);
							  SetTaskEstimate(obj,kTask,sEstimate);
			
			function init(obj,varargin)
			%child classes should use this function to initialize class-specific
			%stuff before a possible manual history dump
				
			end
		end
%/METHODS-----------------------------------------------------------------------

end
