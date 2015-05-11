function x = demean(x,varargin)
% demean
% 
% Description:	subtract the mean from an array of values
% 
% Syntax:	x = demean(x,[dim]=1)
% 
% In:
% 	x		- an array
%	[dim]	- the dimension across which to calculate the mean
% 
% Out:
% 	x	- the demeaned array 
% 
% Updated: 2015-05-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if nargin>1
	dim	= varargin{1};
else
	dim	= 1;
end

%calculate the mean
	m	= mean(x,dim);
%repmat the mean
	s		= size(x);
	sr		= ones(size(s));
	sr(dim)	= s(dim);
	
	mr	= repmat(m,sr);
%subtract
	x	= x - mr;
