classdef Log < PTB.Object
% PTB.Log
% 
% Description:	use to log events
% 
% Syntax:	lg = PTB.Log(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Open:				open the log file
%				Close:				close the log file
%				Append:				append a log event
%				ToString:			convert the log contents to a string
% 
% In:
%	parent	- the parent object
% 	<options>:
%		event_hide:	(false) true to hide all event messages, false to hide none,
%					or a cell of event types to hide
% 
% Updated: 2011-12-17
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
		%----------------------------------------------------------------------%
		function lg = Log(parent)
			lg	= lg@PTB.Object(parent,'log');
		end
		%----------------------------------------------------------------------%
		function Start(lg,varargin)
		% start the log
			opt	= ParseArgs(varargin,...
					'event_hide'	, false	  ...
					);
			
			if ~islogical(opt.event_hide)
				opt.event_hide	= ForceCell(opt.event_hide);
			end
			
			lg.parent.Info.Set('log','event_hide',opt.event_hide,'replace',false);
			lg.parent.Info.Set('log','fill_type',16,'replace',false);
			lg.parent.Info.Set('log','info_cutoff',64,'replace',false);
			
			lg.Open;
			lg.AddLog('started');
		end
		%----------------------------------------------------------------------%
		function End(lg,varargin)
		% end the log
			lg.AddLog('ended');
			lg.Close;
		end
		%----------------------------------------------------------------------%
		function AddLog(lg,varargin)
			lg.Append('log',varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
