function b = SendEmailByTemplate(cTemplate,ifo,varargin)
% SendEmailByTemplate
% 
% Description:	send email to multiple recipients, replacing text in the
%				template based on a struct array of information
% 
% Syntax:	b = SendEmailByTemplate(cTemplate,ifo,<options>)
% 
% In:
% 	cTemplate	- the template string or the path to a template, or an N-length
%				  cell of such. the first line of the template is the subject
%				  and the rest is the message with placeholders. placeholders
%				  should be named as "<blah>", where "blah" refers to a struct
%				  element of ifo, and will be replaced for each message with the
%				  contents of the element.
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
%		error_if_empty:	(true) true to abort sending a message if a struct
%						member for that message is empty
%		error_if_left:	(true) true to abort sending a message if <blah> strings
%						are left after replacement
% 
% Out:
% 	b	- an Nx1 logical array specifying which messages were successfully sent
%
% Assumptions:  assumes PrepEmail has been called
% 
% Updated: 2015-01-04
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'confirm'			, true	, ...
			'test'				, false	, ...
			'file'				, {}	, ...
			'error_if_empty'	, true	, ...
			'error_if_left'		, true	  ...
			);
	
	cTemplate	= reshape(ForceCell(cTemplate),[],1);
	
	%make info an Nx1 cell of structs
		if numel(ifo)==1
			ifo	= restruct(ifo);
		end
		
		ifo	= reshape(num2cell(ifo),[],1);
	
	[cTemplate,ifo]	= FillSingletonArrays(cTemplate,ifo);
	
	cAttachment	= ForceCell(opt.file);
	nAttachment	= numel(cAttachment);

%get the template contents
	bLoad				= FileExists(cTemplate);
	cTemplate(bLoad)	= cellfun(@fget,cTemplate(bLoad),'uni',false);

%send each message
	b	= cellfunprogress(@SendMessage,cTemplate,ifo,...
			'label'	, 'Sending Electronic Email Messages'	  ...
			);


%------------------------------------------------------------------------------%
function b = SendMessage(strTemplate,ifo)
	b	= false;
	
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
	
	if iscell(ifo.email)
		strEmail	= join(ifo.email,', ');
	else
		strEmail	= ifo.email;
	end
	
	%parse the subject
		[strSubject,bUnFilled,bEmptyField]	= StringFillTemplate(strSubject,ifo);
		
		if bUnFilled && opt.error_if_left
			status(sprintf('Unreplaced template holders found for %s!',strEmail),'warning',true);
			return;
		end
		
		if bEmptyField && opt.error_if_empty
			status(sprintf('Empty fields found for %s!',strEmail),'warning',true);
			return;
		end
	
	%parse the message
		[strMessage,bUnFilled,bEmptyField]	= StringFillTemplate(strMessage,ifo);
		
		if bUnFilled && opt.error_if_left
			status(sprintf('Unreplaced template holders found for %s!',strEmail),'warning',true);
			return;
		end
		
		if bEmptyField && opt.error_if_empty
			status(sprintf('Empty fields found for %s!',strEmail),'warning',true);
			return;
		end
	
	%confirm sending
		if opt.confirm
			disp(sprintf('TO: %s',strEmail));
			disp(sprintf('SUBJECT: %s',strSubject));
			disp('MESSAGE:');
			disp(repmat('-',[1 75]));
			disp(strMessage);
			disp(repmat('-',[1 75]));
			
			if ~askyesno('Send?','dialog',false)
				status(sprintf('Sending message to %s aborted.',strEmail),'warning',true);
				return;
			end
		end
	
	%send the message
		try
			if ~opt.test
				if nAttachment>0
					sendmail(ifo.email,strSubject,strMessage,cAttachment);
				else
					sendmail(ifo.email,strSubject,strMessage);
				end
			else
				status('just a test. email not sent.');
			end
			
			b	= true;
		catch me
			status(sprintf('Sending error: %s',me.message),'warning',true);
		end
end
%------------------------------------------------------------------------------%

end
