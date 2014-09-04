function d = dist(x,y)
% DIST
% 
% Description:	calculates the distance between points in N-space
% 
% Syntax:	d = dist(x,y)
%
% In:
%	x	- an M1 x ... x Mk x N array of points in N space
%	y	- either a matrix the same size as x or a 1xN length vector
%		  representing a single point in N space
% 
% Out:
%	d	- an M1 x ... x Mk array of distances between x and y
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
s		= size(x);
ndSpace	= s(end);
ndArray	= numel(s);

if numel(y)==ndSpace	%we want to find the distance between a whole bunch of points and a single point
	%reshape y so it faces along the coordinate dimension
	sY			= s;
	sY(1:end-1)	= 1;
	y			= reshape(y,sY);
	
	%now repmat y so we can subtract it from each point
	sY		= s;
	sY(end)	= 1;
	y		= repmat(y,sY);
end

%find the distance between the x's and y's
d	= sqrt( sum( (x-y).^2, ndArray ) );
