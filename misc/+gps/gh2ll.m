function [lat,lng,box,varargout] = gh2ll(gh,varargin)
% geohash.gh2ll
% 
% Description:	calculate the latitude and longitude at the center of a geohash
%				string
% 
% Syntax:	[lat,lng,box,sz] = gps.gh2ll(gh,[sGrid]=4,[sGridFirst]=sGrid)
% 
% In:
% 	gh				- a geohash string (see gps.ll2gh)
%	[sGrid]			- the grid side length used to calculate gh. can be a scalar
%					  for square grids, or a [sLat,sLng] pair
%	[sGridFirst]	- the first division can have a different grid size
% 
% Out:
% 	lat		- the latitude, from -90 to 90 degrees
%	lng		- the longitude, from -180 to 180 degrees
%	box		- the (S,N,W,E) bounding box
%	sz		- the (H,W) size of the bounding box, in meters
%
% Examples:
%	[lat,lng,box,sz] = gps.gh2ll(gps.ll2gh(45,0,10,4,[3 4]),4,[3 4])
% 
% Updated: 2013-05-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent chr cEarth;

if isempty(chr)
	chr	= ['0':'9' 'a':'z' 'A':'Z' '-' '_'];
	
	rEarth	= 6378100;
	cEarth	= 2*pi*rEarth;
end

[sGrid,sGridFirst]	= ParseArgs(varargin,4,[]);
sGridFirst			= unless(sGridFirst,sGrid);
sGrid				= repto(reshape(sGrid,1,[]),[1 2]);
sGridFirst			= repto(reshape(sGridFirst,1,[]),[1 2]);

%get the grid characters
	chrGrid			= reshape(chr(1:prod(sGrid)),sGrid(1),sGrid(2));
	chrGridFirst	= reshape(chr(1:prod(sGridFirst)),sGridFirst(1),sGridFirst(2));

res	= numel(gh);

box	= [-90 90 -180 180];

[bFirst,kGFirst]	= ismember(gh(1),chrGridFirst);
[b,kG]				= ismember(gh(2:end),chrGrid);

[yGFirst,xGFirst]	= ind2sub(sGridFirst,kGFirst);
[yG,xG]				= ind2sub(sGrid,kG);

kG	= [kGFirst kG];
yG	= [yGFirst yG];
xG	= [xGFirst xG];

for r=1:res
	rngLat	= box(2)-box(1);
	rngLng	= box(4)-box(3);
	
	hCell	= rngLat/conditional(r==1,sGridFirst(1),sGrid(1));
	wCell	= rngLng/conditional(r==1,sGridFirst(2),sGrid(2));
	
	box	=	[
				box(1) + hCell*(yG(r) - 1)
				box(1) + hCell*yG(r)
				box(3) + wCell*(xG(r) - 1)
				box(3) + wCell*xG(r)
			];
end

lat	= mean(box(1:2));
lng	= mean(box(3:4));

if nargout>3
	varargout{1}	=	[
							cEarth*(box(2)-box(1))/360;
							cos(lat*pi/180)*cEarth*(box(4)-box(3))/360;
						];
end
