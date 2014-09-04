function [cK,cKM] = filterBreak(sM,f,varargin)
% FILTERBREAK
% 
% Description:	breaks up a matrix for filtering by chunks so that we don't
%				get an OUT OF MEMORY error
% 
% Syntax:	[cK,cKM] = filterBreak(sM,f,[nMax]=75,000,000/8)
%
% In:
%	sM		- the size of the matrix to filter
%	f		- the filter
%	[nMax]	- the maximum number of elements in each block after calling
%			  filterPrepare
% 
% Out:
%	cK	- a cell of block sized arrays of the scalar indices for each point
%		  in the block
%	cKM	- a cell of cells of the multi-dimensional index intervals for each
%		  block
%
% Example:	s			= [600 800];
%			M			= rand(s);
%			r			= 10; d = 2*r+1; f = MaskCircle(d);
%			M			= padArrayExt(M,r,'replicate');
%			MO			= M;
%			[cK,cKM]	= filterBreak(M,f,10000000);
%			for k=1:numel(cK)
%				[mC,ndN,fC]	= filterPrepare(MO,f,cK{k});
%				M(cKM)		= sum(mC .* fC);
%			end
%
% Assumptions:	assumes your array is small enough so that a block can
%				be at least as big as one nd-1 slice out of the array.  if
%				that's not the case, you're in trouble.
%
% Notes: I doubt this is optimal.  It evolved from an earlier version and I
%		 don't want to spend any more time on it now
%
% Updated:	2009-04-01
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
nMax	= ParseArgs(varargin,75000000/8);	%this gives us 1e8MB per matrix

nKTotal		= prod(sM);
nd			= numel(sM);

%find the number of elements per block
	nF		= numel(find(f~=0));
	nKPer	= floor(nMax ./ nF);
	
%find the area of one slice out of the array
	sA		= prod(sM(1:end-1));

%how many of these can we fit per block?
	nSPer	= min(sM(end),floor(nKPer ./ sA));

%size of each block
	sBlock	= [sM(1:end-1) nSPer];
	nKBlock	= prod(sBlock);
	
%size of the last block
	nB			= ceil(nKTotal ./ nKBlock);
	wLast		= sM(end) - (nB-1)*nSPer;
	if wLast==0
		wLast	= nSPer;
	end
	sLast	= [sM(1:end-1) wLast];
	
%construct the offset blocks
	cOffsetB	= offsetIndices(sBlock);
	cOffsetL	= offsetIndices(sLast);
%construct the blocks
	offsetB			= [zeros(1,nd-1) nSPer];
	[cK,cKM]		= deal(cell(1,nB));
	
	if nB>1
		[cKM{1:end-1}]	= deal(cOffsetB);
	end
	cKM{end}		= deal(cOffsetL);
	[cK{:}]			= deal(cell(1,nd));
	for kB=1:nB
		for kD=1:nd
			cKM{kB}{kD}	= cKM{kB}{kD} + (1 + offsetB(kD).*(kB-1));
		end
		[cK{kB}{1:nd}]	= ndgrid(cKM{kB}{:});
		cK{kB}			= sub2ind(sM,cK{kB}{:});
	end
	