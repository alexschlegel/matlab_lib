function p = z2p(z)
% z2p
% 
% Description:	calculate the probability that a z-score of z occurs by chance
% 
% Syntax:	p = z2p(z)
% 
% Updated:	2012-01-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
%p	= 1-double(int('exp(-x^2/2)/sqrt(2*pi)',-Inf,abs(z)))
p	= 1 - erf(abs(z)/sqrt(2));
