function h = filecounter(varargin)
% filecounter
% 
% Description:	a file-based counter
% 
% Syntax:	h = filecounter('action','start') OR
%			c = filecounter(h,<options>);
% 
% In:
% 	[h]	- the handle to a filecounter
%	<options>:
%		action:			('start'/'step') the action to take. one of the
%						following:
%							'start':	start the counter (default if no handle
%										is specified
%							'get':		get the current counter value
%							'step':		increment the counter
%							'stop':		stop the counter
%		lock_timeout:	(10000) the timeout, in milliseconds, of the lock file.
%						set to false to wait forever
% 
% Out:
% 	h	- the filecounter handle
%	c	- the new filecounter value
% 
% Updated: 2015-06-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	[h,opt]	= ParseArgs(varargin,[],...
				'action'		, []	, ...
				'lock_timeout'	, 10000	  ...
				);
	
	opt.action	= unless(opt.action,conditional(isempty(h),'start','step'));
	
	opt.action	= CheckInput(opt.action,'action',{'start','get','step','stop'});

%make sure we have a valid counter handle
	if isempty(h) && strcmp(opt.action,'start')
		[h,strPathCounter]	= GetNewHandle;
	else
		assert(~isempty(h),'filecounter handle is undefined');
		strPathCounter	= GetCounterPath(h);
	end

%lock the counter
	LockCounter(strPathCounter,opt.lock_timeout);

switch opt.action
	case 'start'
		InitializeCounter(strPathCounter);
	case 'get'
		h	= GetCounter(strPathCounter);
	case 'step'
		h	= StepCounter(strPathCounter);
	case 'stop'
		DeleteCounter(strPathCounter);
		h	= [];
end

%unlock the counter
	UnlockCounter(strPathCounter);

%------------------------------------------------------------------------------%
function [h,strPathCounter] = GetNewHandle()
	h				= 1;
	strPathCounter	= GetCounterPath(h);
	
	while FileExists(strPathCounter)
		h				= h+1;
		strPathCounter	= GetCounterPath(h);
	end
%------------------------------------------------------------------------------%
function LockCounter(strPathCounter,timeout)
	strPathLock	= GetCounterLockPath(strPathCounter);
	
	if notfalse(timeout)
		tTimeout	= nowms + timeout;
	else
		tTimeout	= inf;
	end
		
	while exist(strPathLock,'file') && nowms<tTimeout
		pause(0.001);
	end
	
	fid	= fopen(strPathLock,'w');
	fclose(fid);
%------------------------------------------------------------------------------%
function UnlockCounter(strPathCounter)
	strPathLock	= GetCounterLockPath(strPathCounter);
	
	if exist(strPathLock,'file')
		delete(strPathLock);
	end
%------------------------------------------------------------------------------%
function strPathLock = GetCounterLockPath(strPathCounter) 
	strPathLock	= [strPathCounter '.lock'];
%------------------------------------------------------------------------------%
function strPathCounter = GetCounterPath(h)
	strPathCounter	= PathUnsplit(tempdir,'filecounter',num2str(h));
%------------------------------------------------------------------------------%
function InitializeCounter(strPathCounter) 
	SetCounter(strPathCounter,0);
%------------------------------------------------------------------------------%
function SetCounter(strPathCounter,c) 
	fid	= fopen(strPathCounter,'w');
	
	assert(fid~=-1,'could not open filecounter file');
	
	fwrite(fid,c,'uint32');
	
	fclose(fid);
%------------------------------------------------------------------------------%
function c = GetCounter(strPathCounter)
	if exist(strPathCounter,'file')
		fid	= fopen(strPathCounter,'r');
		
		if fid ~= -1
			c	= fread(fid,1,'uint32');
			fclose(fid);
		else
			c	= 0;
		end
	else
		c	= 0;
	end
%------------------------------------------------------------------------------%
function c = StepCounter(strPathCounter)
	if exist(strPathCounter,'file')
		fid	= fopen(strPathCounter,'r+');
		assert(fid~=-1,'could not open filecounter file');
		
		c	= fread(fid,1,'uint32');
		fseek(fid,0,-1);
	else
		fid	= fopen(strPathCounter,'w+');
		assert(fid~=-1,'could not open filecounter file');
		
		c	= 0;
	end
	
	c	= c+1;
	fwrite(fid,c,'uint32');
	
	fclose(fid);
%------------------------------------------------------------------------------%
function DeleteCounter(strPathCounter) 
	if exist(strPathCounter,'file')
		delete(strPathCounter);
	end
%------------------------------------------------------------------------------%
