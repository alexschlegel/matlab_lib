function se = stderrJK(x,varargin)
% stderrJK
% 
% Description:	calculate the standard error of jackknifed values
% 
% Syntax:	se = stderrJK(x,[flag]=0,[kDim]=<first non-singleton dimension>)
% 
% In:
% 	(stderrJK takes the same input arguments as std)
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

n	= s(kDim);

se	= stdJK(x,varargin{:}) ./ sqrt(n);
