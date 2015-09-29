function [r,k] = randFrom(x,varargin)
% randFrom
% 
% Description:	choose random elements of an array
% 
% Syntax:	[r,k] = randFrom(x,[s]=1,<options>)
% 
% In:
% 	x	- an array
%	[s]	- the number of elements in or size of the return array
%	<options>:
%		unique:		(true) true to include each element of x no more than once
%		exclude:	(<none>) an array of values to exclude from x
%		repeat:		(true) true to allow consecutive repeats
%		seed:		(randseed2) the seed to use for randomizing, or false to
%					skip seeding the random number generator
% 
% Out:
% 	r	- an array of random elements from x
%	k	- the indices of the elements of r in x
% 
% Updated: 2015-09-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	[s,opt]	= ParseArgs(varargin,1,...
				'unique'	, true	, ...
				'exclude'	, []	, ...
				'repeat'	, true	, ...
				'seed'		, []	  ...
				);
	
	if numel(s)==1
		s	= [s 1];
	end
	
	if ~isempty(opt.exclude)
		if iscell(x)
			[x,kInclude]	= SetDiffCell(x,opt.exclude);
		else
			[x,kInclude]	= setdiff(x,opt.exclude);
		end
	else
		kInclude	= reshape(1:numel(x),size(x));
	end

	nX	= numel(x);
	nR	= prod(s);

%seed the random number generator
	rng2(opt.seed);

%get the indices of the elements to return
	if opt.unique
		assert(nR<=nX,'No unique matrices are possible with the given values.');
		
		k	= randomize(1:nX,'seed',false);
		k	= reshape(k(1:nR),s);
	elseif opt.repeat
		k	= randi(nX,s);
	else
		assert(nX>=2 || nR<=1,'No non-repeat matrices are possible with the given values.');
		
		k	= [];
		while numel(k)<nR
			k		= [k; randi(nX,[2*nR 1])];
			d		= diff(k);
			k(d==0)	= [];
		end
		
		k	= reshape(k(1:nR),s);
	end
%return the elements
	r	= reshape(x(k),s);
	k	= kInclude(k);
