function k = u2k(u,nPer,varargin)
% u2k
% 
% Description:	convert a number in units to the index in an array that it
%				corresponds to
% 
% Syntax:	k = u2k(u,nPer,[bRound]=true)
% 
% In:
% 	u		- the number, in units
%	nPer	- the number of units per element of the sample (e.g. 0.1s for
%			  data sampled at 10Hz)
%	bRound	- true to round to the nearest integer
% 
% Out:
% 	k	- the array index corresponding to u
% 
% Example:	u2k(0,0.1)==1	(t=0s, rate=100Hz, k=1)
%			u2k(1,0.1)==11	(t=1s, rate=100Hz, k=11)
% 
% Updated:	2008-11-08
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bRound	= ParseArgs(varargin,true);

k	= u/nPer+1;
if bRound
	k	= round(k);
end
