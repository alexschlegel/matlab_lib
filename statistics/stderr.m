function se = stderr(x,varargin)
% stderr
% 
% Description:	calculate the standard error of values in an array
% 
% Syntax:	se = stderr(x,[flag]=0,[kDim]=<first non-singleton dimension>)
% 
% In:
% 	(stderr takes the same input arguments as std)
% 
% Out:
% 	se	- the standard error
% 
% Updated:	2009-03-04
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[flag,kDim]	= ParseArgs(varargin,0,[]);

s		= size(x);

if isempty(s)
	se	= [];
	return;
end

if isempty(kDim)
	kDim	= find(s~=1,1,'first');
end

if numel(s) >= kDim
	n	= s(kDim);
	
	se	= std(x,varargin{:}) ./ sqrt(n);
else
	se	= NaN(s);
end
