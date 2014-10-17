classdef Scheduler < PTB.Object
% PTB.Scheduler
% 
% Description:	use to scheduler function executions
% 
% Syntax:	sch = PTB.Scheduler(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
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
%				SetAutoInterval:	set the interval of the scheduler timer
%				Update:				update a task's properties
% 
% In:
%	parent	- the parent object
% 	<options:
%		scheduler_wait:				(1) the number of milliseconds to wait after
%									checking on the scheduler tasks
%		scheduler_autointerval:	(100) the interval between auto checks of
%									the scheduler tasks, in milliseconds
% 
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
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

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		TCheck;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function sch = Scheduler(parent)
			sch	= sch@PTB.Object(parent,'scheduler');
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
				sch.parent.Info.Set('scheduler','wait',opt.scheduler_wait,'replace',false);
				sch.parent.Info.Set('scheduler','autointerval',opt.scheduler_autointerval,'replace',false);
				sch.parent.Info.Set('scheduler','running',true,'replace',false);
				sch.parent.Info.Set('scheduler','checking',false);
				sch.parent.Info.Set('scheduler','updating',false);
				sch.parent.Info.Set('scheduler','lock_remove',0);
				
				nTaskField	= numel(sch.TASK_FIELD);
				cBlank		= repmat({{}},[1 nTaskField]);
				cArg		= reshape([sch.TASK_FIELD;cBlank],[],1);
				taskBlank	= struct(cArg{:});
				sch.parent.Info.Set('scheduler','task',taskBlank,'replace',false);
				sch.parent.Info.Set('scheduler',{'queue','add'},{},'replace',false);
			
			%start the auto check timer
				sch.TCheck	= timer(...
								'Name'			, 'scheduler_autocheck'			, ...
								'TimerFcn'		, @(varargin) p_AutoCheck(sch)		, ...
								'ExecutionMode'	, 'fixedRate'						  ...
								);
				sch.SetAutoInterval(sch.parent.Info.Get('scheduler','autointerval'));
				
				if sch.parent.Info.Get('scheduler','running')
					sch.Resume;
				end
		end
		%----------------------------------------------------------------------%
		function End(sch,varargin)
		% end the Scheduler object
			try
				sch.Pause;
				delete(sch.TCheck);
			catch me
				sch.AddLog(['error deleting timers (' me.message ')']); 
			end
			
			%do one more run through the task list
				p_AutoCheck(sch);
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
