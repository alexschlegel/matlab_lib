function [xParam,bChoice] = curve2choice(x,t,b,varargin)
% curve2choice
% 
% Description:	simulate subject responses given a set of stimulus values and
%				weibull function parameters
% 
% Syntax:	[xParam,bChoice] = psychocurve.curve2choice(x,t,b,<options>)
% 
% In:
% 	x	- an array of possible stimulus values
%	t	- the t parameter to the weibull function
%	b	- the b parameter to the weibull function
%	<options>:
%		n:		(100) the number of responses to simulate
%		xmin:	(min(x)) the minimum stimulus value
%		g:		(0.5) the lowest expected performance
%		a:		((1+g)/2) the value at threshold
%		noise:	(0) the standard deviation of noise to add to the response
%				frequencies
% 
% Out:
% 	xParam	- an n x 1 array of simulated stimulus values
%	bChoice	- an n x 1 logical array of simulated subject choices
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'n'		, 100		, ...
		'xmin'	, min(x)	, ...
		'g'		, 0.5		, ...
		'a'		, []		, ...
		'noise'	, 0			  ...
		);
opt.a	= unless(opt.a,(1+opt.g)/2);

%get the response fractions for each stimulus value
	f	= max(0,min(1,weibull(x,t,b,opt.xmin,opt.g,opt.a) + opt.noise*randn(size(x))));
%get the correct number of responses at each stimulus value
	nStimulus	= numel(x);
	nPer		= ceil(opt.n/nStimulus);
	xParam		= reshape(repmat(reshape(x,1,[]),[nPer 1]),[],1);
	f			= reshape(repmat(reshape(f,1,[]),[nPer 1]),[],1);
	bChoice		= rand(size(xParam))<=f;
%randomize and cut off
	[xParam,kRand]	= randomize(xParam);
	bChoice			= bChoice(kRand);
	
	xParam	= xParam(1:opt.n);
	bChoice	= bChoice(1:opt.n);
