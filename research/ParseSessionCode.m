function [t,strInit] = ParseSessionCode(strSession,varargin)
% ParseSessionCode
% 
% Description:	parse a session code of the form DDMMMYY<init>
% 
% Syntax:	[t,strInit] = ParseSessionCode(strSession,<options>)
% 
% In:
% 	strSession	- the session code
%	<options>:
%		timeofday:	(0.5) the time of day as fraction of a day or as a time
%					string

% 
% Out:
% 	t		- the time of the scan as number of milliseconds since the epoch
%	strInit	- the subject initials
% 
% Updated: 2013-02-12
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'timeofday'	, 0.5	  ...
		);
if ischar(opt.timeofday)
	opt.timeofday	= (FormatTime(opt.timeofday) - FormatTime('00:00'))/86400000;
end

%treat "o" as "0"
	reD	= '[\dOo]';

re	= ['^(?<date>' reD reD '[A-Za-z]+' reD reD ')(?<init>\w+)$'];
s	= regexp(strSession,re,'names');

if isempty(s)
	t		= NaN;
	strInit	= '';
else
	d		= s.date;
	strInit	= lower(s.init);
	
	%replace "o" with "0"
		re	= ['^(?<day>' reD reD ')(?<month>[A-Za-z]+)(?<year>' reD reD ')'];
		s	= regexp(d,re,'names');
		if ~isempty(s)
			strDay	= regexprep(s.day,'[Oo]','0');
			strYear	= regexprep(s.year,'[Oo]','0');
			d		= [strDay s.month strYear];
		end
	%replace 'deb' with 'feb' (idiot)
		d	= strrep(d,'deb','feb');
	
	t		= FormatTime(d) + opt.timeofday*86400000;
end
