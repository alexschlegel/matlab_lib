function [y,k] = greatest(x,n,varargin)
% greatest
% 
% Description:	return the n greatest values in x
% 
% Syntax:	[y,k] = greatest(x,n,[dim])
% 
% Updated: 2014-02-27
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dim	= ParseArgs(varargin,[]);

sz	= size(x);

if isempty(dim)
	dim	= unless(find(sz~=1,1),1);
end

%sort the values
	[y,k]	= sort(x,dim,'descend');
%get the largest n values
	s		= repmat({':'},[numel(size(x)) 1]);
	s{dim}	= 1:n;
	
	y	= y(s{:});
	k	= k(s{:});
