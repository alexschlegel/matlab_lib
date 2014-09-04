function x = normmean(x,varargin)
% normmean
% 
% Description:	divide the mean from an array of values
% 
% Syntax:	x = normmean(x,[dim]=1)
% 
% In:
% 	x		- an array
%	[dim]	- the dimension across which to calculate the mean
% 
% Out:
% 	x	- the mean-normalized array 
% 
% Updated: 2012-09-24
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dim	= ParseArgs(varargin,1);

%calculate the mean
	m	= mean(abs(x),dim);
%repmat the mean
	s		= size(x);
	sr		= ones(size(s));
	sr(dim)	= s(dim);
	
	mr	= repmat(m,sr);
%subtract
	x	= x ./ mr;
