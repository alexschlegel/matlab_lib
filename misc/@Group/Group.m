classdef Group < Group.Object
% Group
% 
% Description:	the base root Group object
% 
% Syntax:	grp = Group(strType)
%
% 			subclasses:
% 				Info:		stores info
%				File:		read/write files
%				Scheduler:	schedule execution of tasks
%				Status:		show status messages
%				Prompt:		prompt for information
%				Log:		log events
%
% 			methods:
%				<see Group.Object>
%
%			properties:
%				<see Group.Object>
%
% In:
%	strType	- a fieldname-compatible description of the group type
%	<start options>:
%		start:	(true) true to autostart all objects in the group
%		debug:	(0) the debug level.  0==none, 1==test run, 2==development
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function grp = Group(strType,varargin)
			opt	= ParseArgs(varargin,...
					'attach_class'	, {'Info','File','Scheduler','Status','Prompt','Log'}	, ...
					'attach_name'	, []													, ...
					'attach_arg'	, []													, ...
					'start'			, true													  ...
					);
			cOpt	= opt2cell(opt);
			
			grp	= grp@Group.Object([],strType,cOpt{:});
			
			grp.argin	= varargin;
			
			if opt.start
				grp.Start;
			end
		end
		%----------------------------------------------------------------------%
		function Start(grp,varargin)
			opt	= ParseArgs(varargin,...
					'debug'	, 0	  ...
					);
			
			%start the Info object first
				if ~grp.Info.started
					grp.Info.Start(grp.argin{:},varargin{:});
				end
			
			%set some info
				grp.Info.Set({'t','start'},Group.Now,false);
				grp.Info.Set('debug',opt.debug,false);
			
			
			Start@Group.Object(grp,varargin{:});
		end
		%----------------------------------------------------------------------%
		function Abort(grp,varargin)
			Abort@Group.Object(grp,varargin{:});
			
			error([grp.type ' aborted.']);
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
