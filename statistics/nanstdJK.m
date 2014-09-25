function sd = nanstdJK(x,varargin)
% nanstdJK
% 
% Description:	calculate the standard deviation of jackknifed values, ignoring
%				NaNs
% 
% Syntax:	sd = nanstdJK(x,[flag]=0,[kDim]=<first non-singleton dimension>)
% 
% In:
% 	(nanstdJK takes the same input arguments as nanstd)
% 
% Out:
% 	sd	- the standard deviation, from Miller et al. 1998, Psychophysiology
% 
% Updated:	2014-07-24
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[flag,kDim]	= ParseArgs(varargin,0,[]);

s		= size(x);

if isempty(s)
	sd	= [];
	return;
end

if isempty(kDim)
	kDim	= unless(find(s~=1,1,'first'),1);
end

n	= sum(~isnan(x),kDim);

nRep		= ones(size(s));
nRep(kDim)	= s(kDim);

sd	= sqrt((n-1).*nansum((x-repmat(nanmean(x,kDim),nRep)).^2,kDim));
