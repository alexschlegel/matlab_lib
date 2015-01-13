function [err,t,kState,bAbort] = WaitDownOnce(inp,strButton,varargin)
% PTB.Device.Input.WaitDownOnce
% 
% Description:	wait until a button is down once (see PTB.Device.Input.DownOnce)
% 
% Syntax:	[err,t,kState,bAbort] = inp.WaitDownOnce(strButton,[bLog]=true,<options>)
% 
% In:
%	strButton	- the button name
%	[bLog]		- true to add a log event if the button is down
%	<options>:
%		wait_priority:	(PTB.Scheduler.PRIORITY_LOW) only execute scheduler
%						tasks at or above this priority while waiting for the
%						button
%		fabort:			(<none>) the handle to a function to call while waiting
%						to check whether the wait should be aborted. the
%						function must take no arguments.
%
% Out:
%	err		- true if any of the bad buttons were down
%	t		- the time associated with the query
%	kState	- an array of the state indices that were down
%	bAbort	- true if the wait was aborted
%
% Updated: 2015-01-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[bLog,opt]	= ParseArgs(varargin,true,...
				'wait_priority'	, PTB.Scheduler.PRIORITY_LOW	, ...
				'fabort'		, []							  ...
				);

[t,kState]	= deal([]);
bAbort		= false;

inp.DownOnce(strButton,'reset');

bAbortCheck	= ~isempty(opt.fabort);

[b,err]	= deal(false);
while ~b && ~err
	if bAbortCheck && opt.fabort()
		bAbort	= true;
		return;
	end
	
	[b,err,t,kState]	= inp.DownOnce(strButton,bLog);
	
	if ~b
		inp.parent.Scheduler.Wait(opt.wait_priority,PTB.Now+50);
	end
	
end
