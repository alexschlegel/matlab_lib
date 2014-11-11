function b = SendMRIReminder(strName,strEmail,tStart,tDuration,varargin)
% SendMRIReminder
% 
% Description:	send an MRI reminder email
% 
% Syntax:	b = SendMRIReminder(strName,strEmail,tStart,tDuration,<options>)
% 
% In:
% 	strName		- the subject's name
%	strEmail	- the subject's email address
%	tStart		- the scan start time, as number of milliseconds since the epoch
%				  or as a string compatible with FormatTime
%	tDuration	- the scan duration, in hours
%	<options>:
%		confirm:				(true) true to confirm the message contents
%								before sending
%		prepare:				(true) true to prepare/end email settings
%		session_description:	('scanning session') a description of the session
%		cell_phone:				('347-451-6959') the cell phone to list as a
%								contact
%		from_name:				('Alex') the from name
%		from_email:				('schlegel@gmail.com') the from email address
%		you:					('you') what we should call the participant
% 
% Out:
% 	b	- true if the email was successfully sent
% 
% Updated: 2012-12-06
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= false;

opt	= ParseArgs(varargin,...
		'confirm'				, true					, ...
		'prepare'				, true					, ...
		'session_description'	, 'scanning session'	, ...
		'cell_phone'			, '347-451-6959'		, ...
		'from_name'				, 'Alex'				, ...
		'from_email'			, 'schlegel@gmail.com'	, ...
		'you'					, 'you'					  ...
		);

%get the start time in ms since the epoch
	if ischar(tStart)
		tStart	= FormatTime(tStart);
	end
%don't send if the time has already passed
	if tStart<nowms
		status('Time has already passed!');
		return;
	end
%prepare the email settings
	if opt.prepare
		PrepEmail(opt.from_email);
	end
%prepare the email
	ifo.mmdd		= FormatTime(tStart,'mm/dd');
	if isequal(ifo.mmdd(4),'0')
		ifo.mmdd(4)	= [];
	end
	if isequal(ifo.mmdd(1),'0')
		ifo.mmdd(1)	= [];
	end
	
	ifo.session		= opt.session_description;
	
	ifo.time		= StringTrim(lower(FormatTime(tStart,'HH:MMPM')));
	ifo.duration	= FormatDuration(tDuration);
	ifo.day			= FormatTime(tStart,'informal_day');
	
	ifo.name		= strName;
	ifo.email		= strEmail;
	ifo.cell		= opt.cell_phone;
	ifo.from		= opt.from_name;
	ifo.you			= opt.you;
%send it
	strDir			= PathGetDir(mfilename('fullpath'));
	strPathTemplate	= PathUnsplit(strDir,'mri_reminder','template');
	
	b	= SendEmailByTemplate(strPathTemplate,ifo,'confirm',opt.confirm);
%end the email settings
	if opt.prepare
		EndEmail
	end

%------------------------------------------------------------------------------%
function strDuration = FormatDuration(tDuration)
	if tDuration<1
		strDuration	= [tostring(roundn(tDuration*60,0)) ' minute'];
	else
		strDuration	= [tostring(roundn(tDuration,-2)) ' hour'];
	end
%------------------------------------------------------------------------------%

