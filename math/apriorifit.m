function [fo,g,ft] = apriorifit(x,y,varargin)
% apriorifit
% 
% Description:	fit a curve to a set of data without a fixed model
% 
% Syntax:	[fo,g,ft] = apriorifit(x,y,<options>)
% 
% In:
% 	x	- a column of x data
%	y	- a column of y data
%	<options>:
%		threshold:	(0.95) if the r-squared value of a fit exceeds this
%					threshold then the function stops trying new fit functions
%		fits:		(<see below>) a cell of fit types in the order they will be
%					tried.  each entry can either be a fit type or a cell in
%					which the first element is the fit type and the remaining
%					elements are 'prop'/val pairs for the fit type.
% 
% Out:
% 	fo	- the fit object for the best-fit fit type (see fit)
%	g	- a struct of goodness-of-fit measures
%	ft	- the fit type used
% 
% Updated: 2011-02-18
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
warning('off','curvefit:fit:noStartPoint');
warning('off','curvefit:fit:equationBadlyConditioned');

opt	= ParseArgs(varargin,...
		'threshold'	, 0.95	, ...
		'fits'		, []	  ...
		);
if isempty(opt.fits)
	opt.fits	=	{
						'poly1'
						'exp1'
						fittype('a - b*exp(-d*x)')	%diminishing returns?
						fittype('a/(b+exp(-c*x))')	%sigmoid
						'poly2'
						'poly3'
						'sin1'
						'poly4'
						'poly5'
					};
end

cFit	= cellfun(@ForceCell,opt.fits,'UniformOutput',false);
nFit	= numel(opt.fits);

%try fitting until we pass threshold or run out of fits
	[fo,g]	= deal(cell(nFit,1));
	r2		= zeros(nFit,1);
	
	for kF=1:nFit
		[fo{kF},g{kF}]	= fit(x,y,cFit{kF}{:});
		
		r2(kF)	= g{kF}.rsquare;
		
		if r2(kF)>=opt.threshold
			fo	= fo{kF};
			g	= g{kF};
			ft	= opt.fits{kF};
			
			return;
		end
	end
%nothing passed threshold.  keep the best fit
	kBest	= unless(find(r2==max(r2),1),1);
	fo		= fo{kBest};
	g		= g{kBest};
	ft		= opt.fits{kBest};
