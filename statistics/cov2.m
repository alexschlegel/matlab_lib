function c = cov2(x,y,varargin)
% cov2
% 
% Description:	calculate the covariance of one vector with a set of other
%				vectors
% 
% Syntax:	c = cov2(x,y,<options>)
% 
% In:
% 	x	- an Nx1 array
%	y	- an s1 x ... x sM x N array
%	<options>:
%		'norm':	(0)	0->normalize by N-1
%					1->normalize by N
% 
% Out:
% 	c	- an s1 x ... x sM array of the covariances of x with the corresponding
%		  vectors in y
% 
% Updated: 2010-04-10
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'norm'	, 0	  ...
		);

n	= numel(x);
sz	= size(y);
nd	= numel(sz);

mx	= mean(x);
my	= repmat(mean(y,nd),[ones(1,nd-1) n]);

x	= repmat(reshape(x,[ones(1,nd-1) n]),[sz(1:nd-1) 1]);

c	= sum(((x-mx).*(y-my))./(n-1+opt.norm),nd);
