function [im,alpha] = colorize(b,col,varargin)
% splatter.colorize
% 
% Description:	colorize a logical splatter image
% 
% Syntax:	[im,alpha] = splatter.colorize(b,col,<options>)
% 
% In:
% 	b	- a logical splatter image
%	col	- an Nx3 color palette
%	<options>:
%		p:	(<uniform>) an Nx1 array specifying the probability of choosing
%			each color
% 
% Out:
% 	im		- the colorized splatter pattern
%	alpha	- the alpha map
% 
% Updated: 2013-05-19
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'p'	, []	  ...
		);

nCol	= size(col,1);

opt.p	= unless(opt.p,ones(nCol,1));

alpha	= b;

%find each splatter
	L		= bwlabeln(b);
	nObj	= max(L(:));
%get the color for each splatter
	%get the probability distribution
		p	= opt.p./sum(opt.p);
	%sort and get the cdf along the distribution
		[p,kP]	= sort(p);
		cumP	= [0; cumsum(p)];
	%pick random values from 0->1 and find the cdf value closest to them
		r		= rand(nObj,1);
		kCol	= kP(arrayfun(@(x) find(x>=cumP,1,'last'),r));
	
	colObj	= col(kCol,:);
%colorize
	im	= ind2rgb(L,[0 0 0; colObj]);
