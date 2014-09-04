function nB = filterNBlock(sM,f,varargin)
% FILTERNBLOCK
% 
% Description:	returns the number of blocks that will be returned
%				by a call to filterBreak
% 
% Syntax:	nB = filterNBlock(sM,f,varargin)
%
% In:
%	sM		- the size of the matrix to filter
%	f		- the filter
%	[nMax]	- the maximum number of elements in each block after calling
%			  filterPrepare
% 
% Out:
%	nB	- the number of blocks that will be returned
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
nMax	= ParseArgs(varargin,100000000/8);	%this gives us 1e8MB per matrix

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

%total number of blocks
	nB			= ceil(nKTotal ./ nKBlock);
		