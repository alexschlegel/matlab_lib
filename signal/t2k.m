function k = t2k(t,fs,varargin)
% t2k
% 
% Description:	convert a time to an index value
% 
% Syntax:	k = t2k(t,fs,[t0]=0,[bRound]=true)
% 
% In:
% 	t			- the time, in s
%	fs			- the sampling frequency, in Hz
%	[t0]		- the time at index 1, in s
%	[bRound]	- true to round the results
% 
% Out:
% 	k	- the index corresponding to t in an array of data sampled at fs Hz
% 
% Updated:	2009-04-03
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[t0,bRound]	= ParseArgs(varargin,0,true);

k	= (t-t0)*fs + 1;
if bRound
	k	= round(k);
end
