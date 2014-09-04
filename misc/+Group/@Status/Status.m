classdef Status < Group.Object
% Group.Status
% 
% Description:	show status messages
% 
% Syntax:	stat = Group.Status(parent,[strType]='info')
% 
% 			subfunctions:
%				<see Group.Object>
%				Show:	show a status message
% 
% In:
%	parent		- the parent object
%	[strType]	- the type of the object
% 	<start options>:
%		silent:	(false) true to suppress status messages
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function stat = Status(parent,varargin)
			[strType,opt]	= ParseArgsOpt(varargin,'status',...
								'attach_class'	, []	, ...
								'attach_name'	, []	, ...
								'attach_arg'	, []	  ...
								);
			cOpt			= Opt2Cell(opt);
			
			stat	= stat@Group.Object(parent,strType,cOpt{:});
		end
		%----------------------------------------------------------------------%
		function Start(stat,varargin)
			opt	= ParseArgsOpt(varargin,...
					'silent'	, false	  ...
					);
			
			stat.Info.Set('silent',opt.silent,false);
			
			Start@Group.Object(stat,varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
