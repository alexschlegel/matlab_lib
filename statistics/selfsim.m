function ss = selfsim(x)
% selfsim
% 
% Description:	calculate a self-similarity matrix given a sequence of vectors
% 
% Syntax:	ss = selfsim(x)
% 
% In:
% 	x	- an nD x nVector matrix of nVector nD-dimension vectors
% 
% Out:
% 	ss	- the self-similarity matrix of x, such that ss(i,j) is the correlation
%		  between vectors at positions i and j
% 
% Updated: 2012-09-18
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[nD,nV]	= size(x);

ss	= zeros(nV);

for k=1:nV
	ss(end-k+1,:)	= corrcoef2(x(:,k),x');
end
