function g = gCutoff(g,varargin)
% gCutoff
% 
% Description:	cuts off an intensity image at a lower and upper bound
% 
% Syntax:	g = gCutoff(g,[cMin]=0,[cMax]=1)
%
% In:
%	g		- an grayscale image
%	[cMin]	- the cutoff minimum
%	[cMax]	- the cutoff maximum
% 
% Out:
%	g	- g with values outside [cMin cMax] squished into the specified interval
%
% Updated:	2009-04-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[cMin,cMax]	= ParseArgs(varargin,0,1);

g(g < cMin)	= cMin;
g(g > cMax)	= cMax;
