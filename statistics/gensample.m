function [xSample, kSample] = gensample(x, nSample, sSample, varargin)
% gensample
% 
% Description:	generate unique samples of a dataset
% 
% Syntax:	[xSample, kSample] = gensample(x, nSample, sSample, [dim]=1)
% 
% In:
% 	x		- an n1 x ... x nM array
%	nSample	- the number of samples to generate
%	sSample	- the size of each sample  (i.e. the number of elements of the
%			  sampling dimension to include in each sample)
%	[dim]	- the dimension along which to sample
% 
% Out:
% 	xSample	- an N1 x ... x sSample x ... x nM x nSample array of samples
%	kSample	- an nSample x sSample array of the indices included in each sample
% 
% Updated: 2014-01-22
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dim		= ParseArgs(varargin,1);
sX		= size(x);
ndX		= numel(sX);
sDim	= size(x,dim);

%make sure we don't have an impossible task
	sMax	= nchoosek(sDim, sSample);
	if nSample > sMax
		error(['At most ' num2str(sMax) ' unique samples can be generated along dimension ' num2str(dim) ' of the given data set.']);
	end

%generate the sample indices
	kSample	= zeros(0,sSample);
	
	while size(kSample,1) < nSample
		nCur	= size(kSample,1);
		nNeeded	= nSample - nCur;
		
		kSampleCur	= zeros(nNeeded, sSample);
		for kS=1:nNeeded
			kSampleCur(kS,:)	= randsample(sDim, sSample);
		end 
		
		kSample	= unique([kSample; kSampleCur], 'rows');
	end
	
%generate the samples
	%temporarily bring the sampling dimension of x to the front
		kPermute	= [dim 1:dim-1 dim+1:ndX];
		x			= permute(x,kPermute);
	
	sSampleX	= sX(kPermute);
	sSampleX(1)	= sSample;
	
	xSample	= repmat({zeros(sSampleX)}, [nSample 1]);
	
	for kS=1:nSample
		xSample{kS}(:)	= x(kSample(kS,:),:);
	end
	
	%concatenate the samples
		xSample	= cat(ndX+1, xSample{:});
	
	%unpermute the samples
		xSample	= ipermute(xSample, [kPermute ndX+1]);
