function Show(stat,strStatus,varargin)
% PTB.Status.Show
% 
% Description:	show a status message
% 
% Syntax:	stat.Show(strStatus,<options>)
% 
% In:
% 	strStatus	- the status message
%	<options>:
%		time:	(true) true to prepend the message with the time
% 
% Updated: 2011-12-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'time'	, true	  ...
		);

if opt.time
	strStatus	= [FormatTime(PTB.Now) ' - ' strStatus];
end

if ~notfalse(stat.parent.Info.Get('status','silent'))
	disp(strStatus);
end
