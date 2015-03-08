function gc = GrangerCausalityUni(src,dst,varargin)
% GrangerCausality
% 
% Description:	compute the granger causality from one signal to another
% 
% Syntax:	gc = GrangerCausalityUni(src,dst,<options>)
% 
% In:
% 	src	- an nSample x 1 source signal
%	dst	- an nSample x 1 destination signal
%	<options>:
%		lag:		(1) an array specifying the lags to use in the GC
%					calculation. e.g. [1 2 4] will include the 1st, 2nd, and 4th
%					lagged signals.
%		samples:	(<all>) the samples to consider in the computation. these
%					samples define the 'next' signal in the regression.
% 
% Out:
% 	gc	- the granger causality from src to dst
%
% Notes:
%	algorithm taken from the GCCAtoolbox by Anil Seth
%
% Example:
%	n=200; x=randn(n,1); y=[0; x(1:end-1)]; gc=GrangerCausality(x,y);
% 
% Updated: 2015-03-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'lag'		, 1		, ...
		'samples'	, []	  ...
		);

%make sure we're working with Nx1 arrays
	[src,dst]	= varfun(@(x) reshape(x,[],1),src,dst);

	[nSample, ndSrc]	= size(src);
	[nSampleDst,ndDst]	= size(dst);
	
	if nSample ~= nSampleDst
		error('Source and destination data must have the same number of data samples.');
	end

%extract the samples of interest
	%get the samples to include
		maxLag	= max(opt.lag);
		
		kStartNext	= maxLag + 1;
		kEndNext	= nSample;
		
		if isempty(opt.samples)
			kSampleNext	= kStartNext:kEndNext;
		else
			kSampleNext	= opt.samples(opt.samples>=kStartNext & opt.samples<=kEndNext);
		end
	
	%construct past and next signals
		srcPast	= ConstructPasts(src);
		dstPast	= ConstructPasts(dst);
		dstNext	= ConstructPast(dst,0);

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
	xPast	= demean(x(kSampleNext - lag));
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
