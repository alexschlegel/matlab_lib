classdef difficultymatch < handle
% subject.difficultymatch
% 
% Description:	helper object to match difficulty between a set of tasks.
% 
% Syntax: obj = difficultymatch(n,<options>)
% 
% Methods:
%	AppendProbe:	append the results of a probe
%	CompareTasks:	compare the performance of each task to confirm that
%					difficulties were matched
%	GetNextProbe:	get the next difficulty value to use for a probe. difficulty
%					is encoded as a number between 0 and 1.
%	GetTaskInfo:	get some information about a task's performance history
% 
% Properties:
%	n:			(r) the total number of times each task will be probed
%	k:			(r) an nTask x 1 array of the number of times each task has been
%				probed
%	target:		(r) the target fraction of tasks that the subject should get
%				correct
%	assessment:	(r) a record of a previous assessment of the subject's ability
%				on the tasks. this can either be a subject.assess object or an
%				nTask x 1 array of abilities (i.e. the difficulty at which the
%				target performance level is expected).
%	history:	(r) a struct recording the probe history
% 
% In:
%	n	- the initial value of the <n> property
%	<options>:
%		assessment:	(0.5) the value of the <assessment> property
%		target:		(<from the assessment, or 0.75>) the value of the <target>
%					property
%
% Estimate:
%~ nCondition=3;
%~ simAbility = 0.2*(1:nCondition);
%~ chance = 0.25;
%~ f = arrayfun(@(a) @(d,varargin) subject.assess.base.SimulateProbe(d,varargin{:},'ability',a,'chance',chance),simAbility,'uni',false);
%~ a = subject.assess.stairstep(f,'chance',chance);
%~ a.Run('max',50);
%~ nTrial=40;
%~ dm = subject.difficultymatch(nTrial,'assessment',a);
%~ for kT=1:nTrial
%~ 	for kC=1:nCondition
%~ 		d = dm.GetNextProbe(kC);
%~ 		b = f{kC}(d);
%~ 		dm.AppendProbe(kC,d,b);
%~ 	end
%~ end
% 
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%PUBLIC
		properties (SetAccess=public, GetAccess=public)
			
		end
	
	%READ-ONLY
		properties (SetAccess=protected, GetAccess=public)
			n			= NaN;
			k			= [];
			target		= NaN;
			assessment	= [];
			history		= [];
		end
	
	%PRIVATE
		properties (Constant, SetAccess=protected, GetAccess=protected)
			ATYPE_ASSESS	= 1;
			ATYPE_ARRAY		= 2;
		end
		properties (SetAccess=protected, GetAccess=protected)
			nTask;
			
			assessType;
			
			position		= [];
			speed			= [];
			acceleration	= [];
			dNext			= [];
		end
%/PROPERTIES--------------------------------------------------------------------

%PROPERTY GET/SET---------------------------------------------------------------
	methods
		function t = get.assessType(obj)
			if isa(obj.assessment,'subject.assess.base')
				t	= obj.ATYPE_ASSESS;
			elseif isnumeric(obj.assessment)
				t	= obj.ATYPE_ARRAY;
			else
				error('invalid assessment type');
			end
		end
		function nTask = get.nTask(obj)
			switch obj.assessType
				case obj.ATYPE_ASSESS
					nTask	= numel(obj.assessment.f);
				case obj.ATYPE_ARRAY
					nTask	= numel(obj.assessment);
			end
		end
		function k = get.k(obj)
			if isempty(obj.history)
				k	= zeros(obj.nTask,1);
			else
				kTask	= (1:obj.nTask)';
				k		= arrayfun(@(k) sum(obj.history.task==k),kTask);
			end
		end
%~ 		function obj = set.<PROPERTY>(obj,x)
%~ 			
%~ 		end
	end
%/PROPERTY GET/SET--------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = difficultymatch(n,varargin)
				obj = obj@handle();
				
				%parse the inputs
					opt	= ParseArgs(varargin,...
							'assessment'	, 0.5	, ...
							'target'		, []	  ...
					);
					
					assert(isscalar(n) && isint(n) && n>0,'n must be a positive integer');
					
					obj.n			= n;
					obj.assessment	= opt.assessment;
					
					if isempty(opt.target)
						switch obj.assessType
							case obj.ATYPE_ASSESS
								obj.target	= obj.assessment.target;
							case obj.ATYPE_ARRAY
								obj.target	= 0.75;
						end
					else
						obj.target	= opt.target;
					end
				
				%initialize the history
					obj.history	= repmat(dealstruct('task','d','result',[]),[0 0]);
				
				%initialize the difficulty positions
					nTask	= obj.nTask;
					
					%position
						switch obj.assessType
							case obj.ATYPE_ASSESS
								obj.position	= obj.assessment.ability;
							case obj.ATYPE_ARRAY
								obj.position	= obj.assessment;
						end
						
						assert(all(obj.position>=0) && all(obj.position)<=1,'assessment abilities must be between 0 and 1');
						
						obj.dNext	= obj.position;
					%speed
						obj.speed	= zeros(nTask,1);
					%acceleration
						obj.acceleration	= ones(nTask,1)/obj.n;
			end
		end
	
	%PUBLIC
		methods (Access=public)
		
		end
	
	%PRIVATE
		methods (Access=protected)
			sHistory = GetTaskHistory(obj,kTask);
			sPerformance = GetTaskPerformance(obj,kTask);
		end
%/METHODS-----------------------------------------------------------------------

end
