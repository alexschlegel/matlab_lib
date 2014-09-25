function v = nanvarJK(x,varargin)
% nanvarJK
% 
% Description:	calculate the variance of jackknifed values, ignoring
%				NaNs
% 
% Syntax:	v = nanvarJK(x,[flag]=0,[kDim]=<first non-singleton dimension>)
% 
% In:
% 	(nanvarJK takes the same input arguments as nanvar)
% 
% Out:
% 	v	- the variance, from Miller et al. 1998, Psychophysiology
% 
% Updated:	2014-09-25
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
v	= nanstdJK(x,varargin{:}).^2;
