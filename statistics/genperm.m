function p = genperm(n,nPerm,varargin)
% genperm
% 
% Description:	generate nPerm unique, random permutations of the integers 1:n
% 
% Syntax:	p = genperm(n,nPerm,<options>)
% 
% In:
% 	n		- the number of integers to permute
%	nPerm	- the number of permutations to generate
%	<options>:
%		exclude:	(<none>) an nExclude x n array of permutations to exclude
% 
% Out:
% 	p	- an nPerm x n array of permutations. if fewer than nPerm permutations
%		  are possible, the complete space of permutations is returned.
% 
% Updated: 2015-04-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'exclude'	, zeros(0,n)	, ...
			'seed'		, []			  ...
			);
	
	if isempty(opt.seed)
		opt.seed	= randseed2;
	end
	
%seed the random number generator
	if notfalse(opt.seed)
		rng(opt.seed,'twister');
	end

nMax	= factorial(n);

if nPerm>nMax
	p	= setdiff(perms(1:n),opt.exclude,'rows');
else
	p	= zeros(0,n);
	nNeeded	= nPerm;
	while nNeeded > 0
		pNew	= cell2mat(arrayfun(@randperm,n*ones(nNeeded,1),'uni',false));
		
		if ~isempty(opt.exclude)
			pNew	= setdiff(pNew,opt.exclude,'rows');
		end
		
		p		= unique([p; pNew], 'rows');
		
		nNeeded	= nPerm - size(p,1);
	end
	
	p	= randomize(p,1,'rows','seed',false);
end
