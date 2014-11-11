function [x,t] = ShepardScale(fBase,v,varargin)
% ShepardScale
% 
% Description:	create a sample of a Shepard scale, a seemingly perpetually
%				increasing or decreasing tone
% 
% Syntax:	[x,t] = ShepardScale(fBase,v,[dur]=<one period>,<options>)
% 
% In:
% 	fBase	- the base frequency of the tone
%	v		- the velocity of the tone, in Hz/s
%	<options>
%		rate:	(44100) the sampling rate of the returned signal, in Hz
%		fmax:	(10000) the maximum frequency to include, in Hz
% 
% Out:
% 	x	- the Shepard scale sample
%	t	- the time associated with each point of x
% 
% Updated: 2012-10-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
T	= abs(fBase/v);
sV	= sign(v);

[dur,opt]	= ParseArgs(varargin,T,...
				'rate'	, 44100	, ...
				'fmax'	, 20000	  ...
				);

fA	= 0.5;
dA	= lognpdf(1,fA^2,fA);

%create one period of the scale
	t	= GetInterval(0,dur,dur*opt.rate)';
	nT	= numel(t);
	
	f	= (0:fBase:opt.fmax)';
	nF	= numel(f);
	
	x	= zeros(nT,1);
	for kF=1:nF
		fCur	= f(kF) + sV*fBase.*mod(t/T,1);
		aCur	= lognpdf(fCur/fBase,fA^2,fA)/dA;
		
		x	= x + aCur.*sin(2*pi*fCur.*t);
	end
