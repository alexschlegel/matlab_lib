function [gc,subSrc,subDst] = GrangerCausalitySubsets(src, dst, varargin)
% GrangerCausalitySubsets
% 
% Description:	calculate the multivariate granger causality between every
%				possible subset of specified size of the source and destination
%				signals
% 
% Syntax:	[gc,subSrc,subDst] = GrangerCausalitySubsets(src, dst, <options>)
% 
% In:
% 	src	- an nSample x nVariableSrc source data array
%	dst	- an nSample x nVariableDst destination data array
%	<options>:
%		size:				(1) the maximum number of variables to put in each
%							subset (ONLY 1 IS SUPPORTED CURRENTLY)
%		history:			(1) the number of lags to use for the GC calculation
%		signal_block:		([]) NOT IMPLEMENTED
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	gc		- an nSubsetSrc x nSubsetDst array of multivariate granger
%			  causalities
%	subSrc	- an nSubsetSrc x opt.size array of the variables included in each
%			  source subset
%	subDst	- an nSubsetDst x opt.size array of the variables included in each
%			  destination subset
% 
% Updated: 2014-03-28
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgsOpt(varargin,...
		'size'				, 1		, ...
		'history'			, 1		, ...
		'signal_block'		, []	, ...
		'silent'			, false	  ...
		);

if ~isequal(opt.size,1)
	error('"size" option must be 1.');
end

cOptGC	= Opt2Cell(structsub(opt,{'history','signal_block'}));

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

%calculate the granger causalities
	gc	= NaN(nSubsetSrc, nSubsetDst);
	
	progress(nSubsetSrc,'name','src','silent',opt.silent);
	for kS=1:nSubsetSrc
		for kD=1:nSubsetDst
			gc(kS,kD)	= GrangerCausality(src(:,subSrc{kS}),dst(:,subDst{kD}),cOptGC{:});
		end
		
		progress('name','src');
	end
