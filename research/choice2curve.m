function [tFit,bFit,r2,x,f] = choice2curve(xParam,bChoice,varargin)
% choice2curve
% 
% Description:	construct a psychometric curve based on subject responses
% 
% Syntax:	[tFit,bFit,r2,x,f] = choice2curve(xParam,bChoice,<options>)
% 
% In:
%	xParam	- an array specifying the stimulus value for each trial
% 	bChoice	- a logical array specifying the subject's response on each trial
%	<options>:
%		exclude:	(<none>) an array of values in xParam to exclude
%		tstart:		(<half way between the 2nd percentile of 1s and 98th
%					percentile of 0s>) the starting guess for t (see weibull)
%		bstart:		(1) the starting guess for b (see weibull)
%		xmin:		(min(xParam)) the minimum stimulus value
%		g:			(min(f)) the lowest expected performance
%		a:			((1+g)/2) the peformance at threshold
% 
% Out:
%	tFit	- the fitted threshold (i.e. the x value at which the best-fit
%			  psychometric function reaches the specified threshold value)
%	bFit	- the fitted weibull b parameter (i.e. "slope")
%	r2		- the r^2 (coefficient of determination) of the fit
% 	x		- an Nx1 array of unique stimulus values
%	f		- an Nx1 array of the fraction of the time the subject responses
%			  were "1" for each stimulus value
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'exclude'	, []				, ...
		'tstart'	, []				, ...
		'bstart'	, 1					, ...
		'xmin'		, min(xParam)		, ...
		'g'			, []				, ...
		'a'			, []				  ...
		);

bChoice	= logical(bChoice);

%get the psychometric curve
	x	= reshape(setdiff(unique(xParam),opt.exclude),[],1);
	nU	= numel(x);
	
	f	= NaN(size(x));
	for kU=1:nU
		bX		= xParam==x(kU);
		f(kU)	= sum(bChoice(bX))/sum(bX);
	end
%find t and b values that best fit the data
	opt.g		= unless(opt.g,min(f));
	opt.a		= unless(opt.a,(1+opt.g)/2);
	
	if isempty(opt.tstart)
		opt.tstart	= (prctile(xParam(bChoice),2) + prctile(xParam(~bChoice),98))/2;
	end
	
	try
		ft			= fittype('abs(weibull(x,t,b,xmin,g,a))','coefficients',{'t','b'},'problem',{'xmin','g','a'});
		[fo,gf,op]	= fit(x,f,ft,'problem',{opt.xmin, opt.g, opt.a},'startpoint',[opt.tstart; opt.bstart],'lower',[min(x) 0],'upper',[max(x) inf],'robust','on');
		
		tFit	= fo.t;
		bFit	= fo.b;
		r2		= gf.rsquare;
	catch me
		[tFit,bFit,r2]	= deal(NaN);
	end
