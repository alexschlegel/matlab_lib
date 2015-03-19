function x = bitsub(a,b)
% bitsub
% 
% Description:	subtract two numbers represented as bit arrays. assumes a>=b.
% 
% Syntax:	x = bitsub(a,b)
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nA		= numel(a);
nB		= numel(b);

if nB<nA
	b(end+1:nA)	= false;
end

x	= false(1,nA);

for k=1:nA
	if a(k)
		if ~b(k)
			x(k)	= true;
		end
	elseif b(k)
		kOne	= k+find(a(k+1:end),1);
		
		if isempty(kOne)
			x	= [];
			return;
		end
		
		a(kOne)			= false;
		a(k+1:kOne-1)	= true;
		x(k)			= true;
	end
end

x	= unless(x(1:find(x,1,'last')),false);
