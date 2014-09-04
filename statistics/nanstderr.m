function se = nanstderr(x,varargin)
% nanstderr
% 
% Description:	calculate the standard error of values in an array, ignoring
%				NaNs
% 
% Syntax:	se = nanstderr(x,[flag]=0,[kDim]=1)
% 
% In:
% 	(nanstderr takes the same input arguments as nanstd)
% 
% Out:
% 	se	- the standard error
% 
% Updated:	2009-03-04
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[flag,kDim]	= ParseArgs(varargin,0,[]);

s		= size(x);

if isempty(x)
	se	= NaN;
	return;
end

if isempty(kDim)
	kDim	= find(s~=1,1,'first');
end

n	= sum(~isnan(x),kDim);

se	= nanstd(x,flag,kDim) ./ sqrt(n);
