function varargout = status(str,varargin)
% status
% 
% Description:	display a status message
% 
% Syntax:	n = status(str,[n]=<see below>,<options>) OR
%			status('stop log')
%
% In:
%	str				- the string to display
%	[n]				- optional, the indentation level of the message.  defaults
%					  to one less than the calling function's position in the
%					  function stack
%	<options>:
%		time:		(nowms) the nowms time to display
%		ms:			(false) true to show milliseconds
%		noffset:	(0) offset the indentation by this value
%		logpath:	(<none>) path to a log file to which to write the status
%					messages and all future messages until status('stop log') is
%					called or a new log path is specified
%		logtitle:	(<none>) title of the log file
%		error:		(false)	true if the message is in response to a MATLAB
%					error.  if this is true, the error message is printed along
%					with the status message
%		warning:	(false) true if the status is a warning message
%		silent:		(false) true to suppress output
%
% Out:
%	n	- the value of n used above
% 
% Side-effects:	displays a status update and optionally writes the message to a
%				log file
%
% Updated: 2013-07-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent strPathLog tLogStart;

%parse optional arguments
	[n,opt]	= ParseArgs(varargin,[],...
				'time'		, nowms			, ...
				'ms'		, false			, ...
				'noffset'	, 0				, ...
				'logpath'	, strPathLog	, ...
				'logtitle'	, []			, ...
				'error'		, false			, ...
				'warning'	, false			, ...
				'silent'	, false			  ...
				);
strFormat	= conditional(opt.ms,'yyyy-mm-dd HH:MM:SS.FFF',[]);

tNow	= opt.time;

%optionally stop the log
	if numel(varargin)==0 && isequal(str,'stop log')
		tLogEnd	= nowms;
		tElapse	= tLogEnd - tLogStart;
		
		strTimeEnd	= FormatTime(tLogEnd,strFormat);
		strElapse	= FormatTime(tElapse,'H:MM:SS.FFF');
		
		fput([10 'Log ended at ' strTimeEnd 10 'Elapsed: ' strElapse],strPathLog,'append',true);
		
		strPathLog	= '';
		return
	end

%get n
	if isempty(n)
		n	= max(0,numel(dbstack)-2);
	end
	n	= n + opt.noffset;
%initialize the log
	if ~isequal(opt.logpath,strPathLog)
		tLogStart	= nowms;
		strPathLog	= opt.logpath;
		
		strHeader	= ['Log started at ' FormatTime(tLogStart,strFormat) 10 10];
		if ~isempty(opt.logtitle)
			strHeader	= ['### ' opt.logtitle ' ###' 10 strHeader];
		end
		
		fput(strHeader,strPathLog);
	end

%construct the status string
	if opt.warning
		str	= ['***WARNING*** ' str];
	end
	strTime		= FormatTime(tNow,strFormat);
	strPre		= [strTime repmat(' ',[1 2*n])];
	strStatus	= [strPre ' - ' str];
	if opt.error
		strStatus	= [strStatus ' (err: ' lasterr ')'];
	end

%display it
	if ~opt.silent
		disp(strStatus);
	end
%write it to the log file
	if ~isempty(strPathLog)
		fput([strStatus 10],strPathLog,'append',true);
	end

%output
	if nargout>0
		varargout{1}	= n;
		
		if nargout>1
			varargout{2}	= tNow;
		end
	end
