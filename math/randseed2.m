function s = randseed2
% randseed2
% 
% Description:	kind of like randseed, but adding time as another factor for
%				randomizing
% 
% Syntax:	s = randseed2
% 
% Updated: 2012-02-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent p nP;

%this part follows randseed
	if isempty(nP)
		p	= primes(131071);
		p	= p(p>=31);
		nP	= numel(p);
	end
	
	%choose a random prime element
		kPrime	= 1 + floor(rand(RandStream.getGlobalStream)*nP);

%but now instead of sticking with that random prime, we'll choose a value based
%on the current time
	k	= mod(kPrime + round(nowms),nP)+1;
	s	= p(k);
