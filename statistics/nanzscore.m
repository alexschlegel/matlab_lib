function z = nanzscore(x,varargin)
% nanzscore
% 
% Description:	zscore data while ignoring NaNs
% 
% Syntax:	z = nanzscore(x,[flag]=0,[kDim]=1)
% 
% In:
% 	(nanzscore takes the same input arguments as zscore)
% 
% Out:
% 	z	- the zscored version of x
% 
% Updated: 2015-04-03
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[flag,dim]	= ParseArgs(varargin,0,[]);

s	= size(x);

if isempty(x)
	z	= x;
	return;
end

if isempty(dim)
	dim	= unless(find(s~=1,1,'first'),1);
end

%copied from zscore
	mu = nanmean(x,dim);
	sigma = nanstd(x,flag,dim);
	sigma0 = sigma;
	sigma0(sigma0==0) = 1;
	z = bsxfun(@minus,x, mu);
	z = bsxfun(@rdivide, z, sigma0);
