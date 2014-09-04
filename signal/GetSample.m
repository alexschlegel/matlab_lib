function [xS,kSample] = GetSample(x,f,varargin)
% GetSample
% 
% Description:	sample fraction f of signal x
% 
% Syntax:	[xS,kSample] = GetSample(x,f,[dim]=<first non-singleton dimension>,[strSampleType]='uniform-random')
% 
% In:
% 	x				- the signal
%	f				- the fraction of x to sample
%	[dim]			- the dimension along which to sample x
%	[strSampleType]	- the type of sample to take.  either:
%						'uniform-random':	sample uniformly throughout the
%											signal, starting at a random point
%						'random':			take randomized samples
% 
% Out:
% 	xS		- the sample of x
%	kSample	- the indices of x that were sampled
% 
% Updated:	2009-04-05
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[dim,strSampleType]	= ParseArgs(varargin,'uniform-random',[]);

s	= size(x);
nd	= numel(s);

%get the dimension along which to sample
	if isempty(dim)
		dim	= find(s~=1,1,'first');
		if isempty(dim)
			s	= 1;
		end
	end

%number of samples to get
	nTotal	= s(dim);
	nSample	= round(f*nTotal);

%reshape x to nTotal x []
	%permute 
		kPermute	= [dim 1:dim-1 dim+1:nd];
		x			= permute(x,kPermute);
		s			= s(kPermute);
	%reshape
		x	= reshape(x,nTotal,[]);

%get the sample indices
	switch lower(strSampleType)
		case 'uniform-random'
			%number of data points per block
				nPer	= nTotal/nSample;
			%get the starting point
				kStart	= round(randBetween(1,nPer));
			%get the sample
				kSample	= round(GetInterval(kStart,nTotal,nSample));
		case 'random'
			kSample	= randomize(1:nTotal);
			kSample	= kSample(1:nSample);
		otherwise
			error(['"' strSampleType '" is not a valid sample type']);
	end

%sample
	xS		= x(kSample,:);
	s(1)	= numel(kSample);
	
%unreshape
	xS			= reshape(xS,s);
	kUnpermute	= [2:dim 1 dim+1:nd];
	xS			= permute(xS,kUnpermute);
	