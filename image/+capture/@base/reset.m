function reset(cap,varargin)
% capture.base.reset
% 
% Description:	stop and reset the acquisition program 
% 
% Syntax:	cap.reset
% 
% Updated: 2013-07-28
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[bStopTimer,bStatus]	= ParseArgs(varargin,true,true);
cap.stop(bStopTimer,bStatus);

cap.init;
cap.disarm;

cap.status('acquisition reset');
