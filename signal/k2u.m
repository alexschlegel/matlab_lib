function u = k2u(k,nPer)
% k2u
% 
% Description:	convert an array index to the number in units that it
%				corresponds to
% 
% Syntax:	u = k2u(k,nPer)
% 
% In:
% 	k		- the array index
%	nPer	- the number of units per element of the sample (e.g. 0.1s for
%			  data sampled at 10Hz)
% 
% Out:
% 	u	- the number, in units, corresponding to k
% 
% Example:	k2u(1,0.1)==0	(t=0s, rate=100Hz, k=1)
%			k2u(11,0.1)==1	(t=1s, rate=100Hz, k=11)
% 
% Updated:	2008-11-08
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
u	= (k-1)*nPer;
