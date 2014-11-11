classdef Log < Group.Object
% Group.Log
% 
% Description:	use to log events
% 
% Syntax:	lg = Group.Log(parent,[strType]='log')
% 
% 			subfunctions:
%				<see Group.Object>
%				Open:		open the log file
%				Close:		close the log file
%				Append:		append a log event
%				ToString:	convert the log contents to a string
% 
% In:
%	parent		- the parent object
%	[strType]	- the type of the object
% 	<start options>:
%		log_hide:	(false) true to hide all log messages, false to hide none,
%					or a cell of event types to hide
%		log_save:	(false) true to save the log to a file
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function lg = Log(parent,varargin)
			[strType,opt]	= ParseArgs(varargin,'log',...
								'attach_class'	, []	, ...
								'attach_name'	, []	, ...
								'attach_arg'	, []	  ...
								);
			cOpt			= opt2cell(opt);
			
			lg	= lg@Group.Object(parent,strType,cOpt{:});
		end
		%----------------------------------------------------------------------%
		function Start(lg,varargin)
		% start the log
			if lg.parent.IsRoot()
				opt	= ParseArgs(varargin,...
						'log_hide'	, false	, ...
						'log_save'	, false	  ...
						);
				
				if ~islogical(opt.log_hide)
					opt.log_hide	= ForceCell(opt.log_hide);
				end
				
				lg.Info.Set('hide',opt.log_hide,false);
				lg.Info.Set('save',opt.log_save,false);
				lg.Info.Set('fill_type',16,false);
				lg.Info.Set('info_cutoff',64,false);
				
				lg.Open;
				lg.Append([lg.type ' started']);
			end
			
			Start@Group.Object(lg,varargin{:});
		end
		%----------------------------------------------------------------------%
		function End(lg,varargin)
		% end the log
			if lg.parent.IsRoot()
				lg.Append([lg.type ' ended']);
				lg.Close;
			end
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
