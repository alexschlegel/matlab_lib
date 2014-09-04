function se = nanstderrJK(x,varargin)
% nanstderrJK
% 
% Description:	calculate the standard error of jackknifed values, ignoring NaNs
% 
% Syntax:	se = nanstderrJK(x,[flag]=0,[kDim]=<first non-singleton dimension>)
% 
% In:
% 	(nanstderrJK takes the same input arguments as nanstd)
% 
% Out:
% 	se	- the standard error, from Miller et al. 1998, Psychophysiology
% 
% Updated:	2012-01-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[flag,kDim]	= ParseArgs(varargin,0,[]);

s		= size(x);

if isempty(s)
	se	= [];
	return;
end

if isempty(kDim)
	kDim	= find(s~=1,1,'first');
end

n	= sum(~isnan(x),kDim);

se	= nanstdJK(x,varargin{:}) ./ sqrt(n);
