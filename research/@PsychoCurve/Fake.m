function [xStim,bResponse] = Fake(p,n,varargin)
% PsychoCurve.Fake
% 
% Description:	fake subject responses with a psychometric curve according to
%				current parameters
% 
% Syntax:	[xStim,bResponse] = p.Fake(n,<options>)
% 
% In:
% 	n	- the number of responses to fake
%	<options>:
%		noise:	(0) the standard deviation of noise to add to the response
%				frequencies
% 
% Out:
% 	xStim		- an n x 1 array of simulated stimulus values
%	bResponse	- an n x 1 logical array of simulated subject responses
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'noise'	, 0	  ...
		);

%get the response fractions for each stimulus value
	f	= max(0,min(1,weibull(p.x,p.t,p.b,p.xmin,p.g,p.a) + opt.noise*randn(size(p.x))));
%get the correct number of responses at each stimulus value
	nStimulus	= numel(p.x);
	nPer		= ceil(n/nStimulus);
	
	xStim	= repmat(p.x,[1 nPer]);
	f		= repmat(f,[1 nPer]);
	t		= repmat(GetInterval(0+1/(nPer+1),1-1/(nPer+1),nPer),[nStimulus 1]);
	
	bResponse	= t < f;
	
	[xStim,kRand]	= randomize(xStim(:));
	bResponse		= bResponse(kRand);
	
	xStim		= xStim(1:n);
	bResponse	= bResponse(1:n);
	