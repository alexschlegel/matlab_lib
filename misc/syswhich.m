function strPathCmd = syswhich(cmd,varargin)
% syswhich
% 
% Description:	get the path to a system command
% 
% Syntax:	strPathCmd = syswhich(cmd,<options>)
% 
% In:
% 	cmd	- the name of the command
%	<option>:
%		error:	(false) true to raise an error if the command doesn't exist
% 
% Out:
% 	strPathCmd	- the path to the command
% 
% Updated: 2014-01-20
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'error'	, false	  ...
		);

%get the path
	[ec,strPathCmd]	= system(['which ' cmd]);
	strPathCmd		= StringTrim(strPathCmd);

%raise an error?
	if opt.error && isempty(strPathCmd)
		error([cmd ' was not found on the path.']);
	end
