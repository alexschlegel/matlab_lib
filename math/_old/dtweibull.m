function y = dtweibull(x,varargin)
% dtweibull
% 
% Description:	derivative with respect to t of the Weibull function of the
%				form:
%					W(x) = g+(1-g-lapse)*(1-exp(-(k*(x-xmin)/(t-xmin))^b))
%				where  k = (-log((1-a-lapse)/(1-g-lapse)))^(1/b)
%					t		= the threshold
%					b		= a parameter determining the slope of the curve
%					xmin	= the minimum stimulus value
%					g		= the minimum expected performance
%					a		= the performance at threshold
%					lapse	= the lapse rate
% 
% Syntax:	y = dtweibull(x,[t]=0.5,[b]=1,[xmin]=0,[g]=0.5,[a]=0.75,[lapse]=0)
% 
% In:
% 	x		- the stimulus value
%	[t]		- the threshold
%	[b]		- a parameter determining the slope of the curve
%	[xmin]	- the minimum stimulus value
%	[g]		- the minimum expected performance
%	[a]		- the performance at threshold
%	[lapse]	- the lapse rate
% 
% Out:
% 	y	- dW(x)/dt
% 
% Updated:	2015-12-04
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[t,b,xmin,g,a,lapse]	= ParseArgs(varargin,0.5,1,0,0.5,0.75,0);

k	= (-log((1-a-lapse)./(1-g-lapse))).^(1./b);
C	= -b.*(1-g).*(k.*(x-xmin)).^b;
y	= C.*exp(-(k.*(x-xmin)./(t-xmin)).^b)./(t-xmin).^(b+1);