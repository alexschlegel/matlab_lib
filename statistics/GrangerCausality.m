function gc = GrangerCausality(src,dst,varargin)
% GrangerCausality
% 
% Description:	compute the granger causality from one signal to another
% 
% Syntax:	gc = GrangerCausality(src,dst,<options>)
% 
% In:
% 	src	- an nSample x 1 source signal
%	dst	- an nSample x 1 destination signal
%	<options>:
%		lag:		(1) an array specifying the lags to use in the GC
%					calculation. e.g. [1 2 4] will include the 1st, 2nd, and 4th
%					lagged signals.
%		src_past:	(<auto>) an nSample x nLag array of the lagged source
%					signals. if unspecified, calculates the lagged signals from
%					the data. use this option if something other than the lagged
%					signals as calculated from the input data should be used.
%					for instance, if the input signals are actually a
%					concatenation of temporally separated signals, then the
%					correctly lagged signals will include samples that are not
%					in the input.
%		dst_past:	(<auto>) the same as src_past, but for the destination
%					signal
% 
% Out:
% 	gc	- the granger causality from src to dest
%
% Notes:
%	algorithm taken from the GCCAtoolbox by Anil Seth
%
% Example:
%	n=200;
%	x = randn(n,1); y=[0; x(1:end-1)];
%	xs=x(1:n/2); ys=y(1:n/2); xb = x(kb); yb=y(kb);
%	gcFull = GrangerCausality(x,y);
%	gcCompare = GrangerCausality(xs,ys);
% 
% Updated: 2015-01-23
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'lag'		, 1		, ...
		'src_past'	, []	, ...
		'dst_past'	, []	  ...
		);

%make sure we're working with Nx1 arrays
	[src,dst]	= varfun(@(x) reshape(x,[],1),src,dst);

%remove the signal means
	[src,dst]	= varfun(@demean,src,dst);

%signal subsets
	maxLag	= max(opt.lag);
	
	if ~isempty(opt.src_past)
		srcPast	= demean(opt.src_past,1);
	else
		srcPast	= ConstructPasts(src);
	end
	
	if ~isempty(opt.dst_past)
		dstPast	= demean(opt.dst_past,1);
		dstNext	= dst;
	else
		dstPast	= ConstructPasts(dst);
		dstNext	= ConstructPast(dst,0);
	end

%granger causality
	C	= RegCov([srcPast dstPast],dstNext);
	S	= RegCov(dstPast,dstNext);
	
	gc	= log(S/C);

%------------------------------------------------------------------------------%
function xPast = ConstructPasts(x)
%construct the set of past (lagged) signals. output is nSample x nLag.
	xPast	= arrayfun(@(lag) ConstructPast(x,lag),opt.lag,'uni',false);
	xPast	= cat(2,xPast{:});
end
%------------------------------------------------------------------------------%
function xPast = ConstructPast(x,lag)
%construct a single past signal
	kStart	= maxLag + 1 - lag;
	kEnd	= numel(x) - lag;
	xPast	= x(kStart:kEnd);
end
%------------------------------------------------------------------------------%
function C = RegCov(reg,d)
%perform linear regression on d using the predictors in reg and return the
%covariance of the residual
	beta	= reg\d;
	err		= d - reg*beta;
	C		= cov(err,1);
end
%------------------------------------------------------------------------------%

end
