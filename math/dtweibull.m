function y = dtweibull(x,varargin)
% dtweibull
% 
% Description:	Derivative with respect to t of the Weibull function of the form:
%					W(x)	= 1 - (1-g)*exp(-(k*(x-xmin)/(t-xmin))^b)
%				where k	= (-log((1-a)/(1-g)))^(1/b)
%					t		= the threshold
%					b		= a parameter determining the slope of the curve
%					xmin	= the minimum stimulus value
%					g		= the minimum expected performance
%					a		= the performance at threshold
% 
% Syntax:	y = dtweibull(x,[t]=0.5,[b]=1,[xmin]=0,[g]=0.5,[a]=0.75)
% 
% In:
% 	x		- the stimulus value
%	[t]		- the threshold
%	[b]		- a parameter determining the slope of the curve
%	[xmin]	- the minimum stimulus value
%	[g]		- the minimum expected performance
%	[a]		- the performance at threshold
% 
% Out:
% 	y	- dW(x)/dt
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[t,b,xmin,g,a]	= ParseArgs(varargin,0.5,1,0,0.5,0.75);

k	= (-log((1-a)./(1-g))).^(1./b);
C	= -b.*(1-g).*(k.*(x-xmin)).^b;
y	= C.*exp(-(k.*(x-xmin)./(t-xmin)).^b)./(t-xmin).^(b+1);