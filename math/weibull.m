function y = weibull(x,varargin)
% weibull
% 
% Description:	Weibull function of the form:
%					W(x)	= 1 - (1-g)*exp(-(k*(x-xmin)/(t-xmin))^b)
%				where k	= (-log((1-a)/(1-g)))^(1/b)
%					t		= the threshold
%					b		= a parameter determining the slope of the curve
%					xmin	= the minimum stimulus value
%					g		= the minimum expected performance
%					a		= the performance at threshold
% 
% Syntax:	y = weibull(x,[t]=0.5,[b]=1,[xmin]=0,[g]=0.5,[a]=0.75)
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
% 	y	- W(x)
% 
% Updated: 2011-11-06
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[t,b,xmin,g,a]	= ParseArgs(varargin,0.5,1,0,0.5,0.75);

k	= (-log((1-a)./(1-g))).^(1./b);
y	= 1-(1-g).*exp(-(k.*(x-xmin)./(t-xmin)).^b);
