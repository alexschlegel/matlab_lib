function sd = stdJK(x,varargin)
% stdJK
% 
% Description:	calculate the standard deviation of jackknifed values
% 
% Syntax:	sd = stdJK(x,[flag]=0,[kDim]=<first non-singleton dimension>)
% 
% In:
% 	(stdJK takes the same input arguments as std)
% 
% Out:
% 	sd	- the standard deviation, from Miller et al. 1998, Psychophysiology
% 
% Updated:	2012-01-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[flag,kDim]	= ParseArgs(varargin,0,[]);

s		= size(x);

if isempty(s)
	sd	= [];
	return;
end

if isempty(kDim)
	kDim	= find(s~=1,1,'first');
end

n	= s(kDim);

nRep		= ones(size(s));
nRep(kDim)	= s(kDim);

sd	= sqrt((n-1)*sum((x-repmat(mean(x,kDim),nRep)).^2,kDim));
