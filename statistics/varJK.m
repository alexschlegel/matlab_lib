function v = varJK(x,varargin)
% varJK
% 
% Description:	calculate the variance of jackknifed values
% 
% Syntax:	v = varJK(x,[flag]=0,[kDim]=<first non-singleton dimension>)
% 
% In:
% 	(varJK takes the same input arguments as var)
% 
% Out:
% 	v	- the variance, from Miller et al. 1998, Psychophysiology
% 
% Updated:	2014-09-25
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
v	= stdJK(x,varargin{:}).^2;
