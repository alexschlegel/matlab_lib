function [y,M,S] = pcaica(x,varargin)
% pcaica
% 
% Description:	perform PCA and then ICA on a set of signals to recover the
%				independent principle components of the signals
% 
% Syntax:	[y,M,S] = pcaica(x,[nComponent]=nSignal)
% 
% In:
% 	x				- an nSample x nSignal array of signals
%	[nComponent]	- the desired number of components (actual number of
%					  returned components may be different)
% 
% Out:
% 	y	- an nSample x nComponent array of PCA/ICA component signals
%	M	- the mixing matrix (x ~ y*M). M(i,j) is the "weight" of component i for
%		  signal j.
%	S	- the separating matrix (y ~ x*S)
% 
% Updated: 2014-01-28
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[nSample, nSignal]	= size(x);

nComponent	= ParseArgs(varargin,nSignal);

%do PCA first using MATLAB functions since fastica seems to crap out with large
%arrays
	[SPCA,yPCA]	= pca(x);
	MPCA		= SPCA';
%do ICA on the components we want to keep
	yPCAComp	= yPCA(:,1:nComponent);
	SPCAComp	= SPCA(:,1:nComponent);
	MPCAComp	= MPCA(1:nComponent,:);
	
	[yICA,MICA,SICA]	= fastica(yPCAComp','verbose','off');
	nCActual			= size(yICA,1);
	
	yICA	= yICA';
	MICA	= MICA';
	SICA	= SICA';
%sort by similarity to the principal components
	kCheck	= 1:nCActual;
	kSort	= NaN(nCActual,1);
	
	for kC=1:nCActual
		MCheck			= abs(MICA(kCheck,kC));
		kMax			= find(MCheck==max(MCheck));
		kSort(kC)		= kCheck(kMax);
		kCheck(kMax)	= [];
	end
	
	y		= yICA(:,kSort);
	MICA	= MICA(kSort,:);
	SICA	= SICA(:,kSort);
%calculate the overall mixing and separating matrices (from PCA followed by ICA)
	M	= MICA*MPCAComp;
	S	= SPCAComp*SICA;
	