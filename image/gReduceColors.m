function [g,c] = gReduceColors(g,binMode,varargin)
% gReduceColors
% 
% Description:	reduce the number of colors shown in grayscale image
% 
% Syntax:	[g,c] = gReduceColors(g,[binMode]='uniform',param1,...,paramN)
%
% In:
%	g			- an grayscale image
%	[binMode]	- 'uniform':			each bin is a uniform size
%									n 	- number of colors to which to reduce g
%				  'variance':			bins are chosen to minimize the intrabin
%										variance
%									n 	- number of colors to which to reduce g
%				  'values_nearest':		map values to their nearest value in the
%										specified array
%									c	- an array of values
%				  'values_variance':	group the values to minimize intrabin
%										variance, then
%										assign each color based on the specified
%										array
%									c	- an array of values
%				  'values_cutoff':		reassign colors to depending on which
%										values they lie between in the cutoff
%										array
%									cO	- an array of bin borders (should have
%										  length n-1, where n is the desired
%										  number of colors
%									[c]	- the colors to which to reassign g.  if
%										  unspecified, uses colors uniformly
%										  spaced between 0 and 1
% 
% Out:
%	g	- the new intensity image
%	c	- the colors in the new image
%
% Updated:	2009-04-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if numel(varargin)==0
	varargin{1}	= binMode;
	binMode		= 'uniform';
end
if ~exist('binMode','var')	|| isempty('binMode') binMode	= 'uniform';	end

switch lower(binMode)
	case 'uniform'
		n	= varargin{1};
		
		mn	= min(g(:));
		mx	= max(g(:));
		
		g	= round(normalize(g)*(n-1))/(n-1);
		g	= g * (mx - mn) + mn;
		
		c	= mn + (0:n-1) * (mx-mn) ./ (n-1);
	case 'variance'
		n	= varargin{1};
		
		g		= repmat(g,[1 1 3]);
		[g,c]	= rgb2ind(g,n,'nodither');
		c		= reshape(c(:,1),1,[]);
		g		= c(g+1);
	case 'values_nearest'
		c	= reshape(varargin{1},1,[]);
		
		cCutoff	= [min(g(:)) mean([c(1:end-1) ; c(2:end)]) max(c(:))+1];
		
		bOld	= g;
		for k=1:numel(cCutoff)-1
			g(bOld>=cCutoff(k) & bOld<cCutoff(k+1))	= c(k);
		end
	case 'values_variance'
		c	= reshape(varargin{1},1,[]);
		n	= numel(c);
		
		g			= repmat(g,[1 1 3]);
		[g,cInd]	= rgb2ind(g,n,'nodither');
		
		[cInd,kSort]	= sort(cInd(:,1));
		
		iKSort			= zeros(1,n);
		iKSort(kSort)	= 1:n;
		
		g			= c(iKSort(g+1));
	case 'values_cutoff'
		cO	= reshape(varargin{1},1,[]);
		n	= numel(cO)+1;
		if numel(varargin)<2
			c	= (0:n-1) ./ (n-1);
		else
			c	= reshape(varargin{2},1,[]);
		end
		
		cO	= [min(g(:)) cO max(g(:))+1];
		
		bOld	= g;
		for k=1:n
			g(bOld>=cO(k) & bOld<cO(k+1))	= c(k);
		end
	otherwise
		error('Invalid bin mode.');
end
