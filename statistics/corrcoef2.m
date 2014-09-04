function [r,stat] = corrcoef2(x,y,varargin)
% corrcoef2
% 
% Description:	calculate the correlation coefficient between one vector and a
%				set of other vectors
% 
% Syntax:	[r,stat] = corrcoef2(x,y,<options>)
% 
% In:
% 	x	- an Nx1 array
%	y	- an s1 x ... x sM x N array
%	<options>:
%		twotail:	(false) true to return two-tailed p-values (i.e. significant
%					for positive or negative correlations)
% 
% Out:
% 	r		- an s1 x ... x sM array of the correlation coefficients between x and
%			  the corresponding vectors in y
%	stat	- a struct of statistics:
%				tails:	- the type of test performed
%				p		- the p-values for each r
%				df		- the degrees of freedom
%				m		- the slope of the best-fit line
%				b		- y-intercept of the best-fit line
%				cutoff	- the minimum correlation that would be significant
% 
% Updated: 2014-03-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'twotail'	, false	  ...
		);

n	= numel(x);
sz	= size(y);
nd	= numel(sz);

%resize x
	x	= repmat(reshape(x,[ones(1,nd-1) n]),[sz(1:end-1) 1]);
%get rid of NaN entries
	bNaN	= isnan(x) | isnan(y);
	x(bNaN)	= NaN;
	y(bNaN)	= NaN;
	nNoNaN	= sum(~bNaN,nd);

%compute some schtuff
	mX		= nanmean(x,nd);
	mXR		= repmat(mX,[ones(1,nd-1) n]);
	mY		= nanmean(y,nd);
	mYR		= repmat(mY,[ones(1,nd-1) n]);
	ssX		= nansum((x-mXR).^2,nd);
	ssY		= nansum((y-mYR).^2,nd);
	
	ssXY	= nansum((x-mXR).*(y-mYR),nd);

%correlation coefficient
	r	= ssXY./sqrt(ssX.*ssY);

%stats
	if nargout>0
		%get the correlation in there
			stat.r	= r;
			
		%significance
			stat.tails	= conditional(opt.twotail,'two','one');
			stat.df		= nNoNaN - 2;
			stat.t		= r.*sqrt(stat.df./(1-r.^2));
			stat.p		= t2p(stat.t,stat.df,opt.twotail);
			
			tCutoff		= p2t(0.05,stat.df,opt.twotail);
			stat.cutoff	= abs(tCutoff./sqrt(tCutoff.^2 + stat.df));
		
		%best-fit parameters
			stat.m	= ssXY./ssX;
			stat.b	= mY-stat.m.*mX;
	end
