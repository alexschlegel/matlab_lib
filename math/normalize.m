function [x,m,o] = normalize(x,varargin)
% normalize
% 
% Description:	normalizes data
% 
% Syntax:	[x,m,o] = normalize(x,<options>)
%
% In:
%	x			- an array
%	<options>:
%		type:			('minmax') the type of normalization to carry out:
%							'minmax': specify a lower and upper bound
%							'min': specify a lower bound
%							'max': specify an upper bound
%							'mean': specify the mean
%							'median': specify the median
%							'boundmean':	specify min/max and mean
%								mean.  the histogram will be pulled to the
%								specified mean.
%		min:			(0) the lower bound
%		max:			(1) the upper bound
%		mean:			(0 (or (max+min)/2 if boundmean)) the mean
%		median:			(0.5) the median
%		thresh:			(0.1) the threshold to use for boundmean (difference
%						between actual and desired mean must be less than
%						thresh%)
%		prctile:		(0) disregard the specified lower and upper percentile
%							of values in the input array (0->1)
%		prctile_min:	(<prctile>) disregard the specified lower percentile of
%						values (overrides prctile)
%		prctile_max:	(<prctile>) disregard the specified upper percentile of
%						values (overrides prctile)
%		
% Out:
%	n	- x normalized
%	m	- the multiplier applied to x
%	o	- the offset applied to x
%
% Updated: 2010-12-09
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isempty(x)
	m	= [];
	o	= [];
	return;
end

opt	= ParseArgs(varargin,...
		'type'			, 'minmax'	, ...
		'min'			, 0			, ...
		'max'			, 1			, ...
		'mean'			, []		, ...
		'median'		, 0.5		, ...
		'thresh'		, 0.1		, ...
		'prctile'		, 0			, ...
		'prctile_min'	, []		, ...
		'prctile_max'	, []		  ...
		);
if isempty(opt.prctile_min)
	opt.prctile_min	= opt.prctile;
end
if isempty(opt.prctile_max)
	opt.prctile_max	= opt.prctile;
end
if isempty(opt.mean)
	if isequal(lower(opt.type),'boundmean')
		opt.mean	= mean([opt.min opt.max]);
	else
		opt.mean	= 0;
	end
end

%the values to set
	bSet	= ~isnan(x);
	
	if ~any(bSet(:))
		m	= 0;
		o	= 0;
		return;
	end
%find the x-values we should consider
	opt.prctile_min	= min(1,max(0,opt.prctile_min));
	opt.prctile_max	= min(1,max(0,opt.prctile_max));
	
	if opt.prctile_min~=0
		xMin		= prctile(x(bSet),100*opt.prctile_min);
		bPrctileMin	= x > xMin;
	else
		xMin		= min(x(bSet));
		bPrctileMin	= true(size(x));
	end
	
	if opt.prctile_max~=0
		xMax		= prctile(x(bSet),100*(1-opt.prctile_max));
		bPrctileMax	= x < xMax;
	else
		xMax		= max(x(bSet));
		bPrctileMax	= true(size(x));
	end
	
	bUse	= bSet & bPrctileMin & bPrctileMax;

m	= NaN;
o	= NaN;

switch lower(opt.type)
	case 'minmax'
		bInf	= ~bSet | isinf(x);
		
		dX	= xMax - xMin;
		dN	= opt.max - opt.min;
		
		if isinf(dX)
			x(bSet & bInf & x<0)	= opt.min;
			x(bSet & bInf & x>0)	= opt.max;
			x(bSet & ~bInf)			= (opt.min + opt.max)./2;
		elseif dX==0
			x(bSet)		= (opt.min + opt.max)./2;
		else
			m	= dN./dX;
			o	= opt.min - xMin.*dN/dX;
			
			x(bSet)	= max(opt.min,min(opt.max,x(bSet).*m + o));
		end
	case 'min'
		m		= 1;
		o		= opt.min - xMin;
		x(bSet)	= max(opt.min,x(bSet) + o);
	case 'max'
		m		= 1;
		o		= opt.max - xMax;
		x(bSet)	= min(opt.max,x(bSet) + o);
	case 'mean'
		m		= 1;
		o		= opt.mean - mean(x(bUse));
		x(bSet)	= x(bSet) + o;
	case 'median'
		m		= 1;
		o		= opt.median - median(x(bUse));
		x(bSet)	= x(bSet) + o;
	case 'boundmean'
		%first normalize to the specified bounds
			x	= normalize(x,'min',opt.min,'max',opt.max);
		%get the histogram
			nHist	= min(255,max(10,numel(x)/10));
			[n,b]	= hist(x(:),nHist);
			[n,b]	= varfun(@(x) reshape(x,[],1),n,b);
			t		= GetInterval(0,1,nHist)';
		%fit the histogram to a function
			f	= fit(t,n,'pchipinterp');
		%pull the histogram to the specified mean
			%the function to pull the t parameter
				ft	= @(t,p) t.^(2.^p);
			%find a value of p the pulls the histogram to the desired mean
				p	= FindP;
			%fit the new histogram
				nNew	= round(f(ft(t,p)));
				x		= histeq(x,nNew);
	otherwise
		error(['"' tostring(opt.type) '" is not a recognized normalization type.']);
end

%------------------------------------------------------------------------------%
function p = FindP
	%do we need to shift right or left?
		mFrom	= mean(x(:));
		mTo		= opt.mean;
		
		sgnShift	= -sign(mFrom - mTo);
	%get a p value that goes too far
		bFound	= false;
		for pTest=GetInterval(1,7,10)
			p		= sgnShift.*pTest;
			mCur	= GetMean(t,b,f,ft,p);
			if -sign(mCur - mTo)~=sgnShift
				bFound	= true;
				break;
			end
		end
		if ~bFound
			p	= sgnShift.*inf;
			return;
		end
	%zero in to a p that passes a tolerance threshold
		p1	= min(0,p);
		p2	= max(0,p);
		while abs((mCur-mTo)./mTo)>opt.thresh/100
			p		= (p1+p2)/2;
			mCur	= GetMean(t,b,f,ft,p);
			
			if mCur-mTo<0
				p1	= p;
			else
				p2	= p;
			end
		end
	
	function m = GetMean(t,b,f,ft,p)
		w	= f(ft(t,p));
		m	= sum(b.*w)./sum(w);
	end
end
%------------------------------------------------------------------------------%

end
