function [x,k] = randomize(x,varargin)
% randomize
% 
% Description:	randomize the elements of an array
% 
% Syntax:	[x,k] = randomize(x,[dim]=<first non-singleton dimension>,['rows'],<options>)
% 
% In:
% 	x			- an n1 x ... x nN array
%	[dim]		- the dimension along which to randomize
%	['rows']	- for 2D arrays, randomizes the rows
%	<options>:
%		seed:	(randseed2) the seed to use for randomizing
% 
% Out:
% 	x	- x randomized
%	k	- the randomized indices along dimension dim
% 
% Updated:	2014-07-26
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[dim,strRows,opt]	= ParseArgs(varargin,[],[],...
						'seed'	, randseed2	  ...
						);

bRows	= isequal(lower(strRows),'rows');

s	= size(x);
nd	= numel(s);

%set the seed
	strm	= RandStream.create('mt19937ar','seed',opt.seed);
	RandStream.setGlobalStream(strm);

%get the dimension along which to randomize
	if isempty(dim)
		dim	= find(s~=1,1,'first');
		if isempty(dim)
			dim	= 1;
		end
	end

%randomize
	if bRows
		[dummy,k]	= sort(rand(s(1),1));
		x			= x(k,:);
	else
		%get the randomizing dimension first
			kPermute	= [dim 1:dim-1 dim+1:nd];
			x			= permute(x,kPermute);
			s			= s(kPermute);
		%reshape to s(dim) x N
			nDim	= s(1);
			x		= reshape(x,nDim,[]);
			n		= size(x,2);
		%get the random indices for each column
			[dummy,k]	= sort(rand(nDim,n));
			kCol		= repmat(1:n,[nDim 1]);
		%randomize
			k		= sub2ind([nDim n],k,kCol);
			x(:)	= x(k);
		%unreshape
			x	= reshape(x,s);
		%unpermute
			kUnpermute	= [2:dim 1 dim+1:nd];
			x			= permute(x,kUnpermute);
	end

end
