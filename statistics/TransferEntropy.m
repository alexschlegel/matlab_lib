function [te,stat] = TransferEntropy(src,dst,varargin)
% TransferEntropy
% 
% Description:	estimate the multivariate transfer entropy between two
%				multidimensional signals. optionally uses the estimation method
%				suggested in Lizier et al. (2011), i.e. subsampling and
%				averaging multiple subsets of the source and destination spaces
%				rather than calculating TE for the full spaces.
% 
% Syntax:	[te,stat] = TransferEntropy(src,dst,<options>)
% 
% In:
% 	src	- an nSample x ndSrc array of source data
%	dst	- an nSample x ndDst array of destination data
%	<options>:
%		lag:			(1) an array specifying the lags to use in the GC
%						calculation. e.g. [1 2 4] will include the 1st, 2nd, and
%						4th lagged signals.
%		samples:		(<all>) the samples to consider in the computation.
%						these samples define the 'next' signal in the
%						regression.
%		kraskov_k:		(4) the Kraskov K parameter value
%		ksg_algorithm:	(1) the KSG algorithm to use (1 or 2)
%		subsamples:		(1) the number of times to subsample the data subsets
%		subsample_size:	(inf) the number of variables to include in each
%						subsample of the source and destination data
%		permutations:	(100) the number of permutations to use for significance
%						testing
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	te		- the estimated multivariate transfer entropy from src to dest
%	stat	- a struct of statistical results of a permutation-based test of
%			  significance of the observed transfer entropy 
% 
% Notes:
%	this is based on relevant code from Joseph Lizier's information dynamics
%	toolkit: https://code.google.com/p/information-dynamics-toolkit/
%	
%	Method is described in:
%		Lizier, J. T., Heinzle, J., Horstmann, A., Haynes, J.-D., & Prokopenko,
%		M. (2011). Multivariate information-theoretic measures reveal directed
%		information structure and task relevant changes in fMRI connectivity.
%		Journal of Computational Neuroscience, 30(1), 85-107.
%		
%		and
%		
%		Lizier, J. T. (2014). JIDT: An information-theoretic toolkit for
%		studying the dynamics of complex systems. Frontiers in Robotics and AI,
%		1(December), 1–20.
%
% Example:
%	nvX=2; nvY=nvX+1; n=1000; covariance=0.2; X=randn(n,nvX); Y=[zeros(1,nvY); covariance*[X(1:end-1,1:end-1).*X(1:end-1,2:end) X(1:end-1,end).*X(1:end-1,1)] randn(n-1,nvY-nvX)]+(1-covariance)*randn(n, nvY); [te,stat] = TransferEntropy(X,Y)
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'lag'				, 1		, ...
		'samples'			, []	, ...
		'kraskov_k'			, 4		, ...
		'ksg_algorithm'		, 1		, ...
		'subsamples'		, 1		, ...
		'subsample_size'	, inf	, ...
		'permutations'		, 100	, ...
		'silent'			, false	  ...
		);

%make sure we got good data
	[nSample,ndSrc]		= size(src);
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

%generate the subsamples
	if isinf(opt.subsample_size) && opt.subsamples==1
		srcPastSubsample	= srcPast;
		dstPastSubsample	= dstPast;
		dstNextSubsample	= dstNext;
	else
		%the number of variables to subsample
			sSubsampleSrc	= min(ndSrc,opt.subsample_size);
			sSubsampleDst	= min(ndDst,opt.subsample_size);
		%total possible number of samples
			nSubsampleSrc	= nchoosek(ndSrc,sSubsampleSrc);
			nSubsampleDst	= nchoosek(ndDst,sSubsampleDst);
		%actual number of samples we'll calculate
			nSubsample	= min([opt.subsamples nSubsampleSrc nSubsampleDst]);
		
		%generate the samples
			srcPastSubsample					= gensample(srcPast,nSubsample,sSubsampleSrc,2);
			[dstPastSubsample,kSubsampleDst]	= gensample(dstPast,nSubsample,sSubsampleDst,2);
			
			dstNextSubsample	= arrayfun(@(k) dstNext(:,kSubsampleDst(k,:)),(1:nSubsample)','uni',false);
			dstNextSubsample	= cat(3,dstNextSubsample{:});
	end

%calculate the TE for each subsample
	te	= CalcTEFromSubsamples(srcPastSubsample,dstPastSubsample,dstNextSubsample,opt.silent);

%optionally calculate significance
	if nargout > 1
		stat	= PermutationTest(@CalcTEFromSubsamples, {srcPastSubsample dstPastSubsample dstNextSubsample}, te, ...
					'permutations'	, opt.permutations	, ...
					'silent'		, opt.silent		  ...
					);
	end

%------------------------------------------------------------------------------%
function te = CalcTEFromSubsamples(srcPastSubsample,dstPastSubsample,dstNextSubsample,varargin)
%calculate the mean TE from a set of subsamples of src and dst
%	srcPastSubsample:	nSample x ndSrc x nLag x nSubsample array of
%						nSubsample subsamples of the source signal past
%	dstPastSubsample:	nSample x ndDst x nLag x nSubsample array of
%						nSubsample subsamples of the destination signal past
%	dstNextSubsample:	nSample x ndDst x nSubsample array of nSubsample
%						subsamples of the destination signal next
	bSilent	= ParseArgs(varargin,true);
	
	[nSample,ndSrc,nLag,nSubsample]	= size(srcPastSubsample);
	
	te	= NaN(nSubsample,1);
	
	progress('action','init','total',nSubsample,'label','computing transfer entropy','silent',bSilent);
	for kS=1:nSubsample
		srcPast	= reshape(srcPastSubsample(:,:,:,kS),nSample,[]);
		dstPast	= reshape(dstPastSubsample(:,:,:,kS),nSample,[]);
		dstNext	= dstNextSubsample(:,:,kS);
		
		te(kS)	= CalcTE(srcPast,dstPast,dstNext);
		
		progress;
	end
	
	te	= mean(te);
end
%------------------------------------------------------------------------------%
function te = CalcTE(srcPast,dstPast,dstNext)
%calculate a single TE
%	srcPast:	nSample x ndSrc*nLag array of the source signal pasts
%	dstPast:	nSample x ndDst*nLag array of the destination signal
%				pasts
%	dstNext:	nSample x ndDst array of the destination signal next
	%mutual information of pasts
		[miPast,PNorm,srcNorm]	= MutualInformation(dstPast,srcPast,...
									'kraskov_k'		, opt.kraskov_k		, ...
									'ksg_algorithm'	, opt.ksg_algorithm	  ...
									);
	
	%calculate the PastNext norm using info from the Past norm
		NNorm	= ComputeMaxNorm(zscore(dstNext));
		PNNorm	= max(PNorm, NNorm);
	
	%mutual information of pasts and next
		miPastNext	= MutualInformation([dstPast dstNext],srcPast,...
						'kraskov_k'		, opt.kraskov_k			, ...
						'ksg_algorithm'	, opt.ksg_algorithm		, ...
						'xnorm'			, PNNorm				, ...
						'ynorm'			, srcNorm				  ...
						);
	
	te	= miPastNext - miPast;
end
%------------------------------------------------------------------------------%
function xPast = ConstructPasts(x)
%construct the set of past (lagged) signals. output is nSample x nDim x nLag.
	xPast	= arrayfun(@(lag) ConstructPast(x,lag),opt.lag,'uni',false);
	xPast	= cat(3,xPast{:});
end
%------------------------------------------------------------------------------%
function xPast = ConstructPast(x,lag)
%construct a single past signal
	xPast	= x(kSampleNext - lag,:);
end
%------------------------------------------------------------------------------%
function XNorm = ComputeMaxNorm(X)
%compute the maximum coordinate difference for every pair of samples in X
%this is like EuclideanUtils.maxNorm
%several things here seem inefficient but this is actually the fastest version
%i have been able to come up with
	nSample		= size(X,1);
	
	XRep1	= repmat(permute(X, [1 3 2]),[1 nSample 1]);
	XRep2	= repmat(permute(X, [3 1 2]),[nSample 1 1]);
	
	XNorm	= max(abs(XRep1 - XRep2),[],3);
	
	bDiag			= logical(eye(nSample));
	XNorm(bDiag)	= inf;
end
%------------------------------------------------------------------------------%

end
