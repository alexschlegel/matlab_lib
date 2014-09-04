function varargout = GradientVector(M)
% GradientVector
% 
% Description:	returns an approximation of the gradient vector at each point
%				of input matrix M
% 
% Syntax:	[g1,...,gN] = GradientVector(M)
%
% In:
%	M	- a matrix
% 
% Out:
%	gK	- the gradient in the K direction
%
% Note: if M is anything but 2D, the gradient will be screwed up along the edges
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
s	= size(M);
nd	= numel(s);

%our filters
	kRel	= relativeIndices(3,nd);
	sF		= [ones(1,nd) nd];
	cF		= cell(sF);
	[cF{:}]	= meshgrid(kRel{:});
	
	%find the distance from each point to the center
	mF			= cell2mat(cF);
	dF			= sqrt(sum(mF.^2,nd+1));
	dF(dF==0)	= 1;
	mF			= mF ./ repmat(dF,[sF]);

%extrapolate along the edges
	if nd==2
		[M,sOld]	= padArrayExt(M,1,'linear');
	else
		[M,sOld]	= padArrayExt(M,1,'replicate');
	end

%gradients
	gK	= cell(1,nd);
	for k=1:nd
		[mK,ndN,f]	= filterPrepare(M,cF{k} ./ dF);
		
		gK{k}		= sum(mK .* f,ndN) ./ 2;
		gK{k}		= gK{k}(sOld{:});
	end
	varargout	= gK;