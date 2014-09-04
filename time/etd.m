function tRemain = etd(f,tStart,varargin)
% etd
%
% Description:	estimate the time left until a process completes
%
% Syntax:	tRemain = etd(f,tStart,[tNow]=<current time>)
%
% In:
%	f		- the fraction of the process completed, or an array of fractional
%			  completions at times specified in the <tnow> option
%	tStart	- the time at which the process begin, in ms from the epoch
%	[tNow]	- an array of times at which f was measured
%	<options>:
%		tnow:	(nowms) the current time
%		format:	('H:MM:SS') the format of the output.  either a format specified
%				by FormatTime, or 'n' to return the ms remaining as a double.
%
% Out:
%	tRemain	- the time remaining, formatted as specified
%
% Updated: 2013-07-30
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent cFit h;

[t,opt]	= ParseArgsOpt(varargin,[],...
			'tnow'		, nowms		, ...
			'format'	, 'H:MM:SS'	  ...
			);
t	= unless(t,opt.tnow);

[f,t]	= varfun(@(x) reshape(x,[],1),f,t);

tElapsed	= t - tStart;
n			= numel(tElapsed);


%estimate the finishing time
	if n==0
	%no points, no estimate
		tTotal	= NaN;
	elseif n==1
	%one point, assume a linear progression
		if f==0
			tTotal	= NaN;
		else
			tTotal	= tElapsed/f;
		end
	else
	%just use the last point
		if f(end)==0
			tTotal	= NaN;
		else
			tTotal	= tElapsed(end)/f(end);
		end
	end
%time remaining
	if ~isnan(tTotal)
		tElapsed	= opt.tnow - tStart;
		tRemain		= max(0,tTotal - tElapsed);
	else
		tRemain	= NaN;
	end
%format the estimate
	if ~isequal(lower(opt.format),'n')
		tRemain	= FormatTime(tRemain,opt.format);
	end
