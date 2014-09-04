function yi = interp1nd(x,y,xi,varargin)
% interp1nd
% 
% Description:	interp1 with n-dimensional y values 
% 
% Syntax:	yi = interp1nd(x,y,xi,...) (see interp1)
% 
% In:
% 	x	- an N x 1 array of x control points
%	y	- an N x d1 x ... x dM array of the y values
%	xi	- a P x 1 array of x values at which to interpolate
% 
% Out:
% 	yi	- a P x d1 x ... x dM array of interpolated values
% 
% Updated: 2010-07-26
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

nX	= numel(x);
nXI	= numel(xi);
s	= size(y);

%break up y
	y	= reshape(y,nX,[]);
	nd	= size(y,2);
	y	= mat2cell(reshape(y,nX,[]),nX,ones(1,nd));
%interpolate for each dimension
	yi	= cellfun(@(yc) interp1(x,yc,xi,varargin{:}),y,'UniformOutput',false);
%reshape
	yi	= reshape(cell2mat(yi),[nXI s(2:end)]);
