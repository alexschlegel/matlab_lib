function varargout = status(str,varargin)
% status
% 
% Description:	display a status message
% 
% Syntax:	n = status(str,[n]=<auto>,<options>)
%
% In:
%	str	- the string to display
%	[n]	- optional, the indentation level of the message.  defaults to one less
%		  than the calling function's position in the function stack
%	<options>:
%		time:		(nowms) the nowms time to display
%		ms:			(false) true to show milliseconds
%		noffset:	(0) offset the indentation by this value
%		logpath:	(<none>) path to a log file to which to write the status
%					message
%		error:		(false)	true if the message is in response to a MATLAB
%					error.  if this is true, the error message is printed along
%					with the status message.
%		warning:	(false) true if the status is a warning message
%		silent:		(false) true to suppress output
%
% Out:
%	n	- the value of n used above
% 
% Side-effects:	displays a status update and optionally writes the message to a
%				log file
%
% Updated: 2015-03-11
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse optional arguments
	[n,opt]	= ParseArgs(varargin,max(0,numel(dbstack)-1),...
				'time'		, nowms	, ...
				'ms'		, false	, ...
				'noffset'	, 0		, ...
				'logpath'	, []	, ...
				'error'		, false	, ...
				'warning'	, false	, ...
				'silent'	, false	  ...
				);
	
	strFormat	= conditional(opt.ms,'yyyy-mm-dd HH:MM:SS.FFF',[]);

%construct the status string
	strTime		= FormatTime(opt.time,strFormat);
	nSpace		= max(0,2*(n + opt.noffset));
	strSpacer	= repmat(' ',[1 nSpace]);
	strMod		= conditional(opt.warning,'***WARNING*** ','');
	strError	= conditional(opt.error,sprintf(' (err: %s)',lasterr),'');
	strStatus	= sprintf('%s%s - %s%s%s',strTime,strSpacer,strMod,str,strError);

%display it
	if ~opt.silent
		disp(strStatus);
	end
%write it to the log file
	if ~isempty(opt.logpath)
		fput([strStatus 10],opt.logpath,'append',true);
	end

%output
	if nargout>0
		varargout{1}	= n;
		
		if nargout>1
			varargout{2}	= opt.time;
		end
	end
