function start(cap,varargin)
% capture.base.start
% 
% Description:	start acquiring images
% 
% Syntax:	cap.start(<options>)
% 
% In:
% 	<options>:
%		interval:	(<last or 1000>) the interval between captures, in ms
%		captures:	(10) the number of images to capture
%		tstart:		(<next or nowms>) the nowms start time
% 
% Updated: 2013-07-28
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'interval'	, unless(cap.result.interval,1000)	, ...
		'captures'	, unless(cap.result.remaining,10)	, ...
		'tstart'	, unless(cap.result.next,[])		  ...
		);

tNow	= nowms;
if isempty(opt.tstart)
	opt.tstart	= tNow;
end

cap.result.remaining	= opt.captures;
cap.result.interval		= opt.interval;
cap.result.next			= opt.tstart;

if cap.result.next<tNow
	tDiff		= (tNow - cap.result.next);
	nInterval	= ceil(tDiff/cap.result.interval);
	
	cap.result.next	= cap.result.next + cap.result.interval*nInterval;
end

tInterval	= round(cap.result.interval)/1000;

if opt.captures>0
	set(cap.tmr_acquire,...
		'TasksToExecute'	, opt.captures	, ...
		'Period'			, tInterval		  ...
		);
	
	cap.result.status	= 'running';
	cap.status(['acquisition started (first capture at ' FormatTime(opt.tstart,'yyyy-mm-dd HH:MM:SS.FFF') ')']);
	
	cap.arm(opt.captures);
	
	startat(cap.tmr_acquire,ms2serial(opt.tstart));
else
	cap.status('nothing to do (reset?)');
end
