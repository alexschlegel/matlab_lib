function [te,stat] = TransferEntropy(src,dest,varargin)
% TransferEntropy
% 
% Description:	estimate the multivariate transfer entropy between two
%				multidimensional signals. uses the estimation methods suggested
%				in Lizier et al. (2011), i.e. sampling and averaging multiple
%				subsets of the source and destination spaces rather than
%				calculating TE for the full spaces.
% 
% Syntax:	[te,stat] = TransferEntropy(src,dest,<options>)
% 
% In:
% 	src		- an nSample x nVariableSrc array of source data
%	dest	- an nSample x nVariableDest array of destination data
%	<options>:
%		history:			(1) history length for the TE calculation
%		kraskov_k:			(4) the Kraskov K parameter value
%		sample_variables:	(inf) the number of variables to use for each
%							sampled subset of the source and destination data
%		samples:			(1) the number of times to sample the data subsets
%		permutations:		(100) the number of permutations to use for
%							significance tests
%		signal_block:		(<none>) this is a hack for gridop because my
%							"signals" are actually blocks of 5 samples (one
%							block for each trial) smooshed together, so that
%							comparing the 5th sample of the source to the 5th
%							and 6th samples of the destination (i.e. past to
%							past & next) is meaningless, since the 6th sample is
%							actually the 1st sample of the next, totally
%							unrelated trial. in this case, signal_block:=5.
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	te		- the estimated multivariate transfer entropy from src to dest
%	stat	- a struct of statistical results of a permutation-based test of
%			  significance of the observed transfer entropy 
% 
% Notes:
%	This is a port of relevant code from Joseph Lizier's information dynamics
%	toolkit: https://code.google.com/p/information-dynamics-toolkit/
%	
%	Method is described in:
%		Lizier, J. T., Heinzle, J., Horstmann, A., Haynes, J.-D., & Prokopenko,
%		M. (2011). Multivariate information-theoretic measures reveal directed
%		information structure and task relevant changes in fMRI connectivity.
%		Journal of Computational Neuroscience, 30(1), 85�107.
%
% Example:
%	nvX=2; nvY=nvX+1; n=1000; covariance=0.2; X=randn(n,nvX); Y=[zeros(1,nvY); covariance*[X(1:end-1,1:end-1).*X(1:end-1,2:end) X(1:end-1,end).*X(1:end-1,1)] randn(n-1,nvY-nvX)]+(1-covariance)*randn(n, nvY); [te,stat] = TransferEntropy(X,Y)
% 
% Updated: 2014-03-25
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'history'			, 1		, ...
		'kraskov_k'			, 4		, ...
		'sample_variables'	, inf	, ...
		'samples'			, 1		, ...
		'permutations'		, 100	, ...
		'signal_block'		, []	, ...
		'silent'			, false	  ...
		);

[nSignal, ndSrc]	= size(src);
ndDest				= size(dest,2);

if nSignal ~= size(dest,1)
	error('Source and destination data must have the same number of data samples.');
end

%the number of dimensions to sample
	ndSampleSrc		= min(ndSrc, opt.sample_variables);
	ndSampleDest	= min(ndDest, opt.sample_variables);

%generate the samples
	if isinf(opt.sample_variables) && opt.samples==1
		nSample	= opt.samples;
		
		srcSample	= src;
		destSample	= dest;
	else
		%total possible number of samples
			nSampleAllSrc	= nchoosek(ndSrc, ndSampleSrc);
			nSampleAllDest	= nchoosek(ndDest, ndSampleDest);
		%actual number of samples we'll calculate
			nSample	= min([opt.samples nSampleAllSrc nSampleAllDest]);
		
		%generate the samples
			srcSample	= gensample(src, nSample, ndSampleSrc, 2);
			destSample	= gensample(dest, nSample, ndSampleDest, 2);
	end

%calculate the TE for each sample
	te	= CalcTEFromSamples(srcSample, destSample, opt.silent);

%optionally calculate significance
	if nargout > 1
		stat	= PermutationTest(@CalcTEFromSamples, {srcSample destSample}, te, ...
					'permutations'	, opt.permutations	, ...
					'silent'		, opt.silent		  ...
					);
	end

%------------------------------------------------------------------------------%
function te = CalcTEFromSamples(srcSample, destSample, varargin)
%calculate the mean TE from a set of samples of src and dest
	bSilent	= ParseArgs(varargin,true);
	
	te	= NaN(nSample, 1);
	
	progress(nSample, 'label', 'computing transfer entropy', 'silent', bSilent);
	for kS=1:nSample
		te(kS)	= CalcTE(srcSample(:,:,kS), destSample(:,:,kS));
		
		progress;
	end
	
	te	= mean(te);
end
%------------------------------------------------------------------------------%
function te = CalcTE(src, dest)
%calculate a single TE
%	src:	an nSample x N source data set
%	dest:	an nSample x M destination data set
	ndSrc	= size(src,2);
	ndDest	= size(dest,2);
	
	%construct the data to analyze
		totalObservations	= nSignal - opt.history;
		
		deaPast		= CalcDelayEmbeddingArray(dest, opt.history);
		deaNext		= CalcSingleDelayEmbeddingArray(dest, opt.history+1);
		deaPastNext	= [deaPast deaNext];
		
		srcSub	= src(opt.history:nSignal-1, :);
	
	%optionally remove the block border samples (see documentation)
		if ~isempty(opt.signal_block)
			if opt.history~=1
				error('First figure out the srcSub weirdness!!');
			end
			
			kSkip					= opt.signal_block:opt.signal_block:nSignal-1;
			deaPast(kSkip,:)		= [];
			deaNext(kSkip,:)		= [];
			deaPastNext(kSkip,:)	= [];
			srcSub(kSkip,:)			= [];
		end
		
	%calculate the TE
		%mutual information of pasts
			[miPast,PNorm,srcNorm]	= MutualInformation(deaPast,srcSub,...
										'kraskov_k'		, opt.kraskov_k	  ...
										);
		
		%calculate the PastNext norm using info from the Past norm
			NNorm	= ComputeMaxNorm(zscore(deaNext));
			PNNorm	= max(PNorm, NNorm);
		
		%mutual information of pasts and next
			miPastNext	= MutualInformation(deaPastNext,srcSub,...
							'kraskov_k'		, opt.kraskov_k			, ...
							'xnorm'			, PNNorm				, ...
							'ynorm'			, srcNorm				  ...
							);
		
		te	= miPastNext - miPast;
end
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function y = CalcDelayEmbeddingArray(x, nDelay)
	[nX,ndX]	= size(x);
	
	nY	= nSignal - opt.history;
	y	= zeros(nY,nDelay*ndX);
	
	kCol	= 1:ndX;
	
	for kD=1:nDelay
		kC		= kCol + (kD-1)*ndX;
		y(:,kC)	= CalcSingleDelayEmbeddingArray(x,kD);
	end
end
%------------------------------------------------------------------------------%
function y = CalcSingleDelayEmbeddingArray(x,kDelay)
	nY	= nSignal - opt.history;
	kR	= (1:nY) + kDelay - 1;
	y	= x(kR,:);
end
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function XNorm = ComputeMaxNorm(X)
%compute the maximum coordinate difference for every pair of samples in X
%this is like EuclideanUtils.maxNorm
%several things here seem inefficient but this is actually the fastest version
%i have been able to come up with
	N		= size(X,1);
	
	XRep1	= repmat(permute(X, [1 3 2]),[1 N 1]);
	XRep2	= repmat(permute(X, [3 1 2]),[N 1 1]);
	
	XNorm	= max(abs(XRep1 - XRep2),[],3);
	
	bDiag			= logical(eye(N));
	XNorm(bDiag)	= inf;
end
%------------------------------------------------------------------------------%

end
