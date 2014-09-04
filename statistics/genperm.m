function p = genperm(n,nPerm)
% genperm
% 
% Description:	generate nPerm unique, random permutations of the integers 1:n
% 
% Syntax:	p = genperm(n,nPerm)
% 
% In:
% 	n		- the number of integers to permute
%	nPerm	- the number of permutations to generate
% 
% Out:
% 	p	- an nPerm x n array of permutations. if fewer than nPerm permutations
%		  are possible, the complete space of permutations is returned.
% 
% Updated: 2014-03-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nMax	= factorial(n);

if nPerm>nMax
	p	= perms(1:n);
else
	p	= zeros(0, n);

	nNeeded	= nPerm;
	while nNeeded > 0
		pNew	= cell2mat(arrayfun(@randperm,n*ones(nNeeded,1),'uni',false));
		
		p		= unique([p; pNew], 'rows');
		
		nNeeded	= nPerm - size(p,1);
	end
end
