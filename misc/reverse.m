function x = reverse(x,varargin)
% reverse
% 
% Description:	reverse an array along a specific dimension
% 
% Syntax:	x = reverse(x,[dim]=<first with size>1>)
% 
% In:
% 	x		- an array
%	[dim]	- the dimension along which to reverse
% 
% Out:
% 	x	- x with the specified dimension reverse (i.e. end:-1:1)
% 
% Updated: 2011-02-13
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
dReverse	= ParseArgs(varargin,[]);

s	= size(x);

if isempty(dReverse)
	dReverse	= unless(find(s>1,1),1);
end

%get the index vectors
	cIndex				= arrayfun(@(n) 1:n,s,'UniformOutput',false);
	cIndex{dReverse}	= cIndex{dReverse}(s(dReverse):-1:1);
%reverse
	x	= x(cIndex{:});
