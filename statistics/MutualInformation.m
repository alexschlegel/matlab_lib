function [mi,XNorm,YNorm] = MutualInformation(X, Y, varargin)
% MutualInformation
% 
% Description:	calculate the multivariate mutual information between two
%				multidimensional signals
% 
% Syntax:	[mi,XNorm,YNorm] = MutualInformation(X, Y, <options>)
% 
% In:
% 	X	- an nSample x nVariableX array of data
% 	Y	- an nSample x nVariableY array of data
%	<options>:
%		kraskov_k:		(4) the Kraskov K parameter value
%		ksg_algorithm:	(1) the KSG algorithm to use (1 or 2)
%		xnorm:			(<calculate>) the norms for X
%		ynorm:			(<calculate>) the norms for Y
% 
% Out:
% 	mi		- the multivariate mutual information between X and Y, as calculated
%			  using Kraskov's method (algorithm 2)
%	XNorm	- the calculate norms for X (for future calls to MI.Multivariate)
%	YNorm	- the calculate norms for Y (for future calls to MI.Multivariate)
% 
% Notes:
%	This is a port of relevant code from Joseph Lizier's information dynamics
%	toolkit: https://code.google.com/p/information-dynamics-toolkit/
%	
%	Method is described in:
%		Lizier, J. T., Heinzle, J., Horstmann, A., Haynes, J.-D., & Prokopenko,
%		M. (2011). Multivariate information-theoretic measures reveal directed
%		information structure and task relevant changes in fMRI connectivity.
%		Journal of Computational Neuroscience, 30(1), 85-107.
%		
%		and
%		
%		Lizier, J. T. (2014). JIDT: An information-theoretic toolkit for
%		studying the dynamics of complex systems. Frontiers in Robotics and AI,
%		1(December), 1–20.
% 
% Updated: 2015-02-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'kraskov_k'		, 4		, ...
		'ksg_algorithm'	, 1		, ...
		'xnorm'			, []	, ...
		'ynorm'			, []	  ...
		);

opt.ksg_algorithm	= CheckInput(opt.ksg_algorithm,'KSG algorithm',1:2);

N	= size(X,1);

%normalize the inputs
	X		= zscore(X);
	Y		= zscore(Y);

%get the X norms
	if isempty(opt.xnorm)
		XNorm	= ComputeMaxNorm(X);
	else
		XNorm	= opt.xnorm;
	end
%get the Y Norms
	if isempty(opt.ynorm)
		YNorm	= ComputeMaxNorm(Y);
	else
		YNorm	= opt.ynorm;
	end

%for each sample, get the other samples with which it has the lowest norm
	jointNorm	= max(XNorm, YNorm);
	
	kMins	= NaN(N,opt.kraskov_k);
	for kM=1:opt.kraskov_k
		[m,kMins(:,kM)]	= min(jointNorm,[],2);
		
		kInd			= sub2ind([N N],(1:N)',kMins(:,kM));
		jointNorm(kInd)	= inf;
	end
	
	kRow	= repmat((1:N)',[1 opt.kraskov_k]); 
	kInd	= sub2ind([N N], kRow, kMins);
%get the maximum norm among these
	epsX	= max(XNorm(kInd),[],2);
	epsY	= max(YNorm(kInd),[],2);
%now branch off depending on the algorithm
	switch opt.ksg_algorithm
		case 1
			%maximum norm between X and Y
				epsXY	= max(epsX,epsY);
			%get the number of norms strictly within this norm
				nX	= sum(XNorm < repmat(epsXY,[1 N]),2);
				nY	= sum(YNorm < repmat(epsXY,[1 N]),2);
			%mutual information
				avgDiGammas	= mean(psi(nX+1) + psi(nY+1));
				mi			= psi(opt.kraskov_k) - avgDiGammas + psi(N);
		case 2
			%get the maximum norm among these
				epsX	= max(XNorm(kInd),[],2);
				epsY	= max(YNorm(kInd),[],2);
			%get the number of norms within or at this norm
				nX	= sum(XNorm <= repmat(epsX,[1 N]),2);
				nY	= sum(YNorm <= repmat(epsY,[1 N]),2);
			%mutual information
				avgDiGammas	= mean(psi(nX) + psi(nY));
				mi			= psi(opt.kraskov_k) - 1/opt.kraskov_k - avgDiGammas + psi(N);
	end

%------------------------------------------------------------------------------%
function XNorm = ComputeMaxNorm(X)
%compute the maximum coordinate difference for every pair of samples in X
%this is like EuclideanUtils.maxNorm
%several things here seem inefficient but this is actually the fastest version
%i have been able to come up with
	N		= size(X,1);
	
	XRep1	= repmat(permute(X, [1 3 2]),[1 N 1]);
	XRep2	= repmat(permute(X, [3 1 2]),[N 1 1]);
	
	XNorm	= max(abs(XRep1 - XRep2),[],3);
	
	bDiag			= logical(eye(N));
	XNorm(bDiag)	= inf;
end
%------------------------------------------------------------------------------%

end
