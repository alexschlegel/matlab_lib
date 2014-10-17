classdef FixationTask < PTB.Object
% PTB.FixationTask
% 
% Description:	show a fixation task during stimulus presentation
% 
% Syntax:	ft = PTB.Show.FixationTask(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Go:					start the fixation task
%				Running:			test whether the fixation task is running
%				Result:				get the fixation task results (can be called
%									while the fixation task is going to get the
%									inflight results)
%				Reset:				reset the fixation task results (this happens
%									automatically when starting the task)
% 				Stop:				stop the fixation task
% 
% In:
%	parent	- the parent PTB.Experiment object
% 	<options>:
%		fixation_task_color			('deepskyblue') the color of the fixation task
%									dot
%		fixation_task_rate:			(1/15) the average rate at which the fixation
%									task will be shown during each Show.Sequence,
%									in Hz
%		fixation_task_delay:		(500) the number of milliseconds after the
%									start of the fixation task before a fixation
%									task event can occur
%		fixation_task_dur:			(250) the duration of the fixation task, in
%									milliseconds
%		fixation_task_timeout:		(2000) the number of milliseconds from
%									fixation onset the subject has to respond
%		fixation_task_response:	('any') how the task should check for a
%									correct response.  either a string input to
%									PTB.Input.Down or a function that takes no
%									inputs and returns three outputs:
%										1) a boolean to indicate whether the
%										   subject has responded.
%										2) a boolean to indicate whether the
%										   fixation task should be aborted
%										3) the time associated with the response
% 
% Updated: 2011-12-16	
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function ft = FixationTask(parent)
			ft	= ft@PTB.Object(parent,'fixation_task');
		end
		%----------------------------------------------------------------------%
		function Start(ft,varargin)
		%initialize the FixationTask object
			%parse the options
				opt	= ParseArgs(varargin,...
						'fixation_task_color'		, 'deepskyblue'	, ...
						'fixation_task_cutoff'		, 0.9			, ...
						'fixation_task_rate'		, 1/15			, ...
						'fixation_task_delay'		, 500			, ...
						'fixation_task_dur'			, 250			, ...
						'fixation_task_timeout'	, 2000			, ...
						'fixation_task_response'	, 'any'			  ...
						);
				
				switch class(opt.fixation_task_response)
					case 'char'
						ft.parent.Info.Set('fixation_task','fRespond',@() ft.parent.Input.DownOnce(opt.fixation_task_response,false),'replace',false);
					case 'function_handle'
						ft.parent.Info.Set('fixation_task','fRespond',opt.fixation_task_response,'replace',false);
					otherwise
						error(['"' tostring(opt.fixation_task_response) '" is not a recognized fixation task response.']);
				end
				
				%initialize some task info
					ft.parent.Info.Set('fixation_task','stage',0,'replace',false);
					
					ft.parent.Info.Set('fixation_task','oldcolor',[],'replace',false);
					ft.parent.Info.Set('fixation_task','tGo',[],'replace',false);
					ft.parent.Info.Set('fixation_task','tLast',[],'replace',false);
					ft.parent.Info.Set('fixation_task','tShow',[],'replace',false);
					ft.parent.Info.Set('fixation_task','tResponse',[],'replace',false);
					ft.parent.Info.Set('fixation_task','tStop',[],'replace',false);
					
					ft.parent.Info.Set('fixation_task','response_state',false,'replace',false);
				
				%set some info
					ft.parent.Color.Set('fixation_task',opt.fixation_task_color,'replace',false);
					
					ft.parent.Info.Set('fixation_task','rate',opt.fixation_task_rate,'replace',false);
					ft.parent.Info.Set('fixation_task','delay',opt.fixation_task_delay,'replace',false);
					ft.parent.Info.Set('fixation_task','dur',opt.fixation_task_dur,'replace',false);
					ft.parent.Info.Set('fixation_task','timeout',opt.fixation_task_timeout,'replace',false);
		end
		%----------------------------------------------------------------------%
		function End(ft,varargin)
		% end the FixationTask object
			ft.Stop;
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
