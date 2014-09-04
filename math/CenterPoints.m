function p = CenterPoints(p,varargin)
% CenterPoints
% 
% Description:	translate the points in p so that their center is at c
% 
% Syntax:	p = CenterPoints(p,[c]=<origin>)
% 
% In:
% 	p	- an MxN array of N M-dimensional points
%	[c]	- the new center of the points in p
% 
% Out:
% 	p	- the translated points
% 
% Updated:	2008-11-10
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[M,N]	= size(p);
c		= ParseArgs(varargin,zeros(M,1));

m	= mean(p,2);
d	= reshape(c,[],1)-m;
p	= p + repmat(d,[1 N]);
