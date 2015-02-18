function [te,subSrc,subDst] = TransferEntropySubsets(src, dst, varargin)
% TransferEntropySubsets
% 
% Description:	calculate the multivariate transfer entropy between every
%				possible subset of specified size of the source and destination
%				signals
% 
% Syntax:	[te,subSrc,subDst] = TransferEntropySubsets(src, dst, <options>)
% 
% In:
% 	src	- an nSample x nVariableSrc source data array
%	dst	- an nSample x nVariableDst destination data array
%	<options>:
%		size:				(1) the maximum number of variables to put in each
%							subset
%		history:			(1) history length for the TE calculation
%		kraskov_k:			(4) the Kraskov K parameter value
%		sample_variables:	(inf) the number of variables to use for each
%							sampled subset of the source and destination data
%		samples:			(1) the number of times to sample the data subsets
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	te		- an nSubsetSrc x nSubsetDst array of multivariate transfer
%			  entropies
%	subSrc	- an nSubsetSrc x opt.size array of the variables included in each
%			  source subset
%	subDst	- an nSubsetDst x opt.size array of the variables included in each
%			  destination subset
% 
% Updated: 2015-02-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'size'				, 1		, ...
		'history'			, 1		, ...
		'kraskov_k'			, 4		, ...
		'sample_variables'	, inf	, ...
		'samples'			, 1		, ...
		'silent'			, false	  ...
		);

cOptTE	= opt2cell(structsub(opt,{'history','kraskov_k','sample_variables','samples','silent'}));

nVariableSrc	= size(src,2);
nVariableDst	= size(dst,2);

%get the subsets
	subSrc		= arrayfun(@(s) handshakes(1:nVariableSrc,s),1:opt.size,'uni',false);
	subSrc		= cellfun(@(c) mat2cell(c,ones(size(c,1),1),size(c,2)),subSrc,'uni',false);
	subSrc		= cat(1,subSrc{:});
	nSubsetSrc	= size(subSrc,1);
	
	subDst		= arrayfun(@(s) handshakes(1:nVariableDst,s),1:opt.size,'uni',false);
	subDst		= cellfun(@(c) mat2cell(c,ones(size(c,1),1),size(c,2)),subDst,'uni',false);
	subDst		= cat(1,subDst{:});
	nSubsetDst	= size(subDst,1);

%calculate the transfer entropies
	te	= NaN(nSubsetSrc, nSubsetDst);
	
	progress(nSubsetSrc,'name','src','silent',opt.silent);
	for kS=1:nSubsetSrc
		
		%progress(nSubsetDst,'name','dst','status',false,'silent',opt.silent);
		for kD=1:nSubsetDst
			te(kS,kD)	= TransferEntropy(src(:,subSrc{kS}),dst(:,subDst{kD}),cOptTE{:});
			
			%progress('name','dst');
		end
		
		progress('name','src');
	end
