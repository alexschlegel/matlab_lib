function beepex(varargin)
% beepex
% 
% Description:	extends MATLAB's beep, which doesn't work for me (probably
%				because I have system sounds disabled)
% 
% Syntax:	beepex([dur]=1,[f]=440);
% 
% In:
% 	[dur]	- duration of the beep, in seconds
%	[f]		- frequency of the beep, in Hz
% 
% Side-effects:	beeps
% 
% Updated:	2012-10-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[dur,f]	= ParseArgs(varargin,1,440);

rate	= 44100;

x	= signalgen(f,dur,'rate',rate);

wavplay(x,rate,'async');
