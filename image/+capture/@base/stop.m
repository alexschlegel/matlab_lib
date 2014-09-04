function stop(cap,varargin)
% capture.base.stop
% 
% Description:	stop acquiring images
% 
% Syntax:	cap.stop
% 
% Updated: 2013-07-27
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[bStopTimer,bStatus]	= ParseArgs(varargin,true,true);

if bStopTimer
	stop(cap.tmr_acquire);
	cap.result.status	= 'stopped';
	
	if bStatus
		cap.status('acquisition stopped');
	end
else
	cap.result.status	= 'finished';
	
	if bStatus
		cap.status('acquisition finished');
	end
end
