function t = k2t(k,fs,varargin)
% ms2k
% 
% Description:	convert an index to a time value
% 
% Syntax:	t = k2t(k,fs,[t0]=0)
% 
% In:
% 	k		- an index
%	fs		- the sampling frequency, in Hz
%	[t0]	- the time at index 1, in s
% 
% Out:
% 	t	- the time, in s, represented by index k in an array of data sampled at
%		  fs Hz
% 
% Updated:	2008-01-16
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
t0	= ParseArgs(varargin,0);

t	= (k - 1)/fs + t0;
