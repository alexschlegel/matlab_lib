function y = gaussian1(x,varargin)
% gaussian1
% 
% Description:	univariate gaussian distribution of the form:
%					f(x) = (1/sqrt(2*pi*S))*exp(-(x-mu)^2/(2*S))
% 
% Syntax:	y = gaussian(x,[mu]=0,[S]=1)
%
% In:
%	x		- an array of input values
%	[mu]	- the distribution mean value
%	[S]		- the distribution variance
% 
% Updated:	2016-05-25
% Copyright 2016 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
y	= reshape(gaussian(x(:),varargin{:}),size(x));
