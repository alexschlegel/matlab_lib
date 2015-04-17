function Show(stat,strStatus,varargin)
% Group.Status.Show
% 
% Description:	show a status message
% 
% Syntax:	stat.Show(strStatus,<options>)
% 
% In:
% 	strStatus	- the status message
%	<options>:
%		time:	(true) true to prepend the time to the message
% 
% Updated: 2015-04-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'time'	, true	  ...
		);

if opt.time
	strStatus	= [FormatTime(Group.Now) ' - ' strStatus];
end

if ~notfalse(stat.Info.Get('silent'))
	disp(strStatus);
end
