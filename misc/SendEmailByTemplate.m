function b = SendEmailByTemplate(strTemplate,ifo,varargin)
% SendEmailByTemplate
% 
% Description:	send email to multiple recipients, replacing text in the template
%				based on a struct array of information
% 
% Syntax:	b = SendEmailByTemplate(strTemplate,ifo,<options>)
% 
% In:
% 	strTemplate	- the template string or the path to a template.  The first line
%				  of the template is the subject and the rest is the message with
%				  placeholders.  Placeholders should be named as "<blah>", where
%				  "blah" refers to a struct element of ifo, and will be replaced
%				  for each message with the contents of the element.
%	ifo			- an Nx1 struct array defining the replacement values for N
%				  messages.  ifo must at least have the field "email", which
%				  specifies the to email addresses.  can also be a 1x1 struct of
%				  Nx1 arrays
%	<options>:
%		confirm:		(true) true to confirm the contents of each message
%						before sending
%		test:			(false) true to just perform a test run (don't actually
%						send the email)
%		file:			(<none>) the path to a file or cell of paths to files to
%						include with the email
%		error_if_empty:	(true) true to abort sending a message if a struct member
%						for that message is empty
%		error_if_left:	(true) true to abort sending a message if <blah> strings
%						are left after replacement
% 
% Out:
% 	b	- an Nx1 logical array specifying which messages were successfully sent
%
% Assumptions:  assumes PrepEmail has been called
% 
% Updated: 2013-02-05
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'confirm'			, true	, ...
		'test'				, false	, ...
		'file'				, {}	, ...
		'error_if_empty'	, true	, ...
		'error_if_left'		, true	  ...
		);

%files
	opt.file	= ForceCell(opt.file);
	nFile		= numel(opt.file);
%format the struct
	if numel(ifo)==1
		N	= unique(structfun(@numel,ifo));
		
		if numel(N)==1
			ifo2	= struct;
			
			cField	= fieldnames(ifo);
			nField	= numel(cField);
			
			for kF=1:nField
				f							= conditional(iscell(ifo.(cField{kF})),ifo.(cField{kF}),num2cell(ifo.(cField{kF})));
				[ifo2(1:N).(cField{kF})]	= deal(f{:});
			end
			
			ifo	= ifo2;
		end
	end

%get the template contents
if FileExists(strTemplate)
	strTemplate	= fget(strTemplate);
end

%split by subject/message
	kLine	= regexp(strTemplate,'\r\n|\n');
	if isempty(kLine)
		kLine	= numel(strTemplate)+1;
	else
		kLine	= kLine(1);
	end
	
	strSubject	= strTemplate(1:kLine-1);
	strMessage	= strTemplate(kLine+1:end);
	if ~isempty(strMessage) && strTemplate(kLine)==13 && strMessage(1)==10
		strMessage	= strMessage(2:end);
	end

%send each message
	nMessage	= numel(ifo);
	
	b	= false(nMessage,1);
	
	reLeft	= '<[^<>]+>';
	
	[strP,nStatus]	= progress(nMessage,'label','Sending Electronic Email Messages');
	for kM=1:nMessage
		if iscell(ifo(kM).email)
			strEmail	= join(ifo(kM).email,', ');
		else
			strEmail	= ifo(kM).email;
		end
		
		[strSubjectCur,bSuccess]	= StructReplace(strSubject,ifo(kM));
		
		if ~bSuccess
			progress;
			continue;
		end
		
		strMessageCur	= StructReplace(strMessage,ifo(kM));
		
		if opt.error_if_left && (~isempty(regexp(strSubjectCur,reLeft)) || ~isempty(regexp(strMessageCur,reLeft)))
			status(['Unreplaced template holders found for ' strEmail '!'],nStatus+1,'warning',true);
			
			progress;
			continue;
		end
		
		if opt.confirm
			disp(['TO: ' strEmail 10 'SUBJECT: ' strSubjectCur 10 'MESSAGE:' 10 repmat('-',[1 75]) 10 strMessageCur 10 repmat('-',[1 75])]);
			res	= ask('Send?','dialog',false,'choice',{'yes','no','abort'});
			
			if ~isequal(res,'yes')
				if isequal(res,'abort')
					status('Sending messages aborted.','warning',true);
					progress('end');
					break;
				end
				
				status(['Sending message to ' strEmail ' aborted.'],'warning',true);
				progress;
				continue;
			end
		end
		
		try
			if ~opt.test
				if nFile>0
					sendmail(ifo(kM).email,strSubjectCur,strMessageCur,opt.file);
				else
					sendmail(ifo(kM).email,strSubjectCur,strMessageCur);
				end
			else
				status('just a test.  email not sent.');
			end
			
			b(kM)	= true;
		catch me
			status(['Sending error:  ' me.message],'warning',true);
		end
		
		progress;
	end

%------------------------------------------------------------------------------%
function [str,bSuccess] = StructReplace(str,s)
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	bSuccess	= false;
	for kF=1:nField
		if opt.error_if_empty && isempty(s.(cField{kF})) && ~isempty(strfind(str,['<' cField{kF} '>']))
			status(['Empty fields found for ' strEmail ' (' cField{kF} ')!'],'warning',true);
			return;
		end
		
		str	= strrep(str,['<' cField{kF} '>'],tostring(s.(cField{kF})));
	end
	
	bSuccess	= true;
end
%------------------------------------------------------------------------------%

end
