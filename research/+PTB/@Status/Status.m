classdef Status < PTB.Object
% PTB.Status
% 
% Description:	use to show status messages
% 
% Syntax:	stat = PTB.Status(parent)
% 
% 			subfunctions:
%				Start(<options>):	start the object
%				End:				end the object
%				Show:				show a status message
% 
% In:
%	parent	- the parent object
% 	<options>:
%		silent:	(false) true to suppress status messages
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
		%----------------------------------------------------------------------%
		function stat = Status(parent)
			stat	= stat@PTB.Object(parent,'status');
		end
		%----------------------------------------------------------------------%
		function Start(stat,varargin)
			opt	= ParseArgs(varargin,...
					'silent'	, false	  ...
					);
			
			stat.parent.Info.Set('status','silent',opt.silent,'replace',false);
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
