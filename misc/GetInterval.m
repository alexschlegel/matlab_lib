function [x,nStep,xStep] = GetInterval(xStart,xEnd,varargin)
% GetInterval
% 
% Description:	get an interval between two values
% 
% Syntax:	t = GetInterval(xStart,xEnd,[nStep]=<integer steps>) OR
%			t = GetInterval(xStart,xEnd,xStep,'stepsize')
% 
% In:
% 	xStart	- starting value
%	xEnd	- ending value
%	[nStep]	- number of steps from xStart to xEnd.  defaults to integer steps
%	xStep	- step by xstep
% 
% Out:
% 	x		- a 1xN array of values in the interval between xStart and xEnd
%	nStep	- the number of steps
%	xStep	- the size of each step
% 
% Example:	GetInterval(0,5)				== 0:5;
%			GetInterval(0,5,11)				== 0:0.5:5;
%			Getinterval(0,5,0.5,'stepsize')	== 0:0.5:5;
% 
% Updated:	2008-11-04
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

[s,sType]	= ParseArgs(varargin,[],'nstep');

if isempty(s)
	s		= 1;
	sType	= 'stepsize';
end

switch sType
	case 'stepsize'
		xStep	= s;
		x		= xStart:xStep:xEnd;
		nStep	= numel(x);
	otherwise
		nStep	= s;
		if nStep==1
			xStep	= (xEnd-xStart)/2;
			x		= xStart+xStep;
		else
			xStep	= (xEnd-xStart)/(nStep-1);
			t		= 0:nStep-1;
			x		= xStart + t*xStep;
		end
end