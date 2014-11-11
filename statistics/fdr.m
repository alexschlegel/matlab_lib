function [pThresh,varargout] = fdr(p,q,varargin)
% fdr
% 
% Description:	compute a false discovery rate adjusted p threshold for a set of
%				p values.  based on Benjamini and Hochberg (1995 & 2001).
% 
% Syntax:	[pThresh,pAdjusted] = fdr(p,q,<options>)
% 
% In:
% 	p	- an array of p values
%	q	- the desired FDR q-value threshold
%	<options>:
%		mask:		(<none>) a logical array the same size as p denoting the
%					mask used when performing the analysis that created the p
%					values
%		dependent:	(false) true if independence or positive correlation should
%					not be assumed among the p values
% 
% Out:
% 	pThresh		- the p threshold that corresponds to the specified q
%	pAdjusted	- an array of FDR-adjusted p values
% 
% Updated: 2011-02-09
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'mask'		, true(size(p))	, ...
		'dependent'	, false			  ...
		);

opt.mask	= logical(opt.mask);

s	= size(p);
p	= p(opt.mask);
n	= numel(p);

%calculate the adjusted p threshold
	[p,kSort]	= sort(p(:));
	k			= (1:n)';
	
	if opt.dependent
		d	= sum(1./k);
	else
		d	= 1;
	end
	
	kLast	= find(p <= q*k/(n*d),1,'last');
	pThresh	= p(kLast);
%calculate the adjusted p values
	if nargout>=2
		p	= n*d*p./k;
		for kP=n-1:-1:1
			p(kP)	= min(p(kP),p(kP+1));
		end
		
		varargout{1}			= NaN(s);
		varargout{1}(opt.mask)	= unsort(p,kSort);
	end
