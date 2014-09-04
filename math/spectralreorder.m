function [M,k] = spectralreorder(M)
% spectralreorder
% 
% Description:	spectral reordering (i hope) of a matrix M. see the following:
%	(1) http://www.pnas.org/content/suppl/2004/08/20/0403743101.DC1/03743SuppText.pdf
%	(2) http://www.nas.nasa.gov/assets/pdf/techreports/1993/rnr-93-015.pdf
%	(3) https://www.cs.purdue.edu/homes/dgleich/demos/matlab/spectral/spectral.html
% 
% Syntax:	[M,k] = spectralreorder(M)
% 
% In:
% 	M	- an NxN matrix. should be pretty close to symmetric.
% 
% Out:
% 	M	- the reordered matrix
%	k	- the sorting order
% 
% Updated: 2014-01-31
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
N	= size(M,1);

%(1) says we need to make sure M has all positive values. it is assuming M
%is a correlation matrix,so C=B+1 may not work here
	C	= M - min(M(:)) + eps;
	
%i don't know what i'm doing. this is something like computing the Laplacian
%matrix for M. taken from (1) which is somehow loosely based on (2).
	Q	= -C;
	
	kDiag		= find(eye(N));
	Q(kDiag)	= 0;
	Q(kDiag)	= -sum(Q,2);
%if M is symmetric then so will be Q. but if not, i'll make it symmetric (hope
%this doesn't blow anything up!).
	Q	= (Q+Q')/2;
%okay, compute the eigenvalues of the Laplacian. taken from (3).
	[V,D]	= eigs(Q, 2, 'SA');
%sort by the second eigenvalue
	[dummy,k]	= sort(V(:,2));
	M			= M(k,k);
