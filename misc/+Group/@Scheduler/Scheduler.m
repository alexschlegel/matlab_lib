classdef Scheduler < Group.Object
% Group.Scheduler
% 
% Description:	schedule function executions
% 
% Syntax:	sch = Group.Scheduler(parent)
% 
% 			subfunctions:
%				<see Group.Object>
%				Add:				add a task to the scheduler
%				Remove:				remove a task from the scheduler
%				Exists:				test whether a task exists
%				Wait:				check on scheduler tasks and wait a brief
%									period for other system processes to execute
%				Result:				get the result of the last call to a task
%				Pause:				pause a task or the scheduler timer
%				Resume:				resume a task or the scheduler timer
%				Running:			test if a task or the scheduler timer is
%									running
%				Update:				update a task's properties
% 
% In:
%	parent		- the parent object
% 	<start options>:
%		scheduler_wait:				(1) the number of milliseconds to wait after
%									checking on the scheduler tasks
%		scheduler_autointerval:	(100) the interval between auto checks of
%									the scheduler tasks, in milliseconds
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		auto_interval;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%CONSTANT PROPERTIES-------------------------------------------------------%
	properties (Constant)
		MODE_RUNONCE	= 1;
		MODE_FINISHED	= 2;
		MODE_ABORTED	= 3;
		MODE_PAUSED		= 4;
		MODE_REMOVE		= 5;
		
		PRIORITY_IDLE		= 0;
		PRIORITY_LOW		= 1;
		PRIORITY_NORMAL		= 2;
		PRIORITY_HIGH		= 3;
		PRIORITY_CRITICAL	= 4;
	end
	%CONSTANT PROPERTIES-------------------------------------------------------%
	
	%PRIVATE CONSTANT PROPERTIES-----------------------------------------------%
	properties (Constant, GetAccess=private)
		TASK_FIELD	= reshape({
						'name'			, ...	%the name of the task
						'priority'		, ...	%priority of the task (0-4)
						'function'		, ...	%function handle
						'arguments'		, ...	%input arguments to function
						'mode'			, ...	%task execution mode
						'interval'		, ...	%task execution interval
						'executions'	, ...	%number of executions
						'nOut'			, ...	%number of outputs
						'output'		, ...	%output results from past function calls
						'tEstimate'		, ...	%duration estimate of each task execution
						'tSetStart'		, ...	%desired first execution time
						'tSetEnd'		, ...	%desired last execution time
						'tStart'		, ...	%actual first execution time
						'tLast'			, ...	%the last execution time
						'tNext'			  ...	%next execution time
						},1,[]);
	end
	%PRIVATE CONSTANT PROPERTIES-----------------------------------------------%

	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		TCheck;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function sch = set.auto_interval(sch,tInterval)
			sch.Info.Set('autointerval',tInterval);

			sch.Pause;
			set(sch.TCheck,'Period',tInterval/1000);
			sch.Resume;
		end
		%----------------------------------------------------------------------%
		function tInterval = get.auto_interval(sch,tInterval)
			tInterval	= sch.Info.Get('autointerval');
		end
		%----------------------------------------------------------------------%
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function sch = Scheduler(parent)
			sch	= sch@Group.Object(parent,'scheduler');
		end
		%----------------------------------------------------------------------%
		function Start(sch,varargin)
		% start the Scheduler object
			%parse the input
				opt	= ParseArgs(varargin,...
						'scheduler_wait'			, 1		, ...
						'scheduler_autointerval'	, 100	  ...
						);
			
			%set some info
				sch.Info.Set('wait',opt.scheduler_wait,false);
				sch.Info.Set('autointerval',opt.scheduler_autointerval,false);
				sch.Info.Set('running',true,false);
				
				sch.Info.Set('checking',false);
				sch.Info.Set('updating',false);
				sch.Info.Set('lock_remove',0);
				
				nTaskField	= numel(sch.TASK_FIELD);
				cBlank		= repmat({{}},[1 nTaskField]);
				cArg		= reshape([sch.TASK_FIELD;cBlank],[],1);
				taskBlank	= struct(cArg{:});
				sch.Info.Set('task',taskBlank,false);
				sch.Info.Set({'queue','add'},{},false);
			
			%start the auto check timer
				sch.TCheck	= timer(...
								'Name'			, 'scheduler_autocheck'		, ...
								'TimerFcn'		, @(varargin) p_AutoCheck(sch)	, ...
								'ExecutionMode'	, 'fixedRate'					, ...
								'Period'		, sch.auto_interval/1000		  ...
								);
				
				if sch.Info.Get('running')
					sch.Resume;
				end
			
			Start@Group.Object(sch,varargin{:});
		end
		%----------------------------------------------------------------------%
		function End(sch,varargin)
		% end the Scheduler object
			try
				sch.Pause;
				delete(sch.TCheck);
			catch me
				sch.Log.Append(['error deleting timers (' me.message ')']); 
			end
			
			%do one more run through the task list
				p_AutoCheck(sch);
			
			End@Group.Object(sch,varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
