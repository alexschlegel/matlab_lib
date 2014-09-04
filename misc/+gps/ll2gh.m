function gh = ll2gh(lat,lng,varargin)
% gps.ll2gh
% 
% Description:	convert a latitude and longitude, in degrees, to a geohash
%				string
% 
% Syntax:	gh = gps.ll2gh(lat,lng,[res]=13,[sGrid]=4,[sGridFirst=sGrid)
% 
% In:
% 	lat				- a latitude, from -90 to 90 degrees
%	lng				- a longitude, from -180 to 180 degrees
%	[res]			- the desired geohash resolution
%	[sGrid]			- the grid side length used to calculate gh. can be a scalar
%					  for square grids, or a [sLat,sLng] pair
%	[sGridFirst]	- the first division can have a different grid size
% 
% Out:
% 	gh	- the geohash string for that location
% 
% Updated: 2013-05-27
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent chr;

if isempty(chr)
	chr	= ['0':'9' 'a':'z' 'A':'Z' '-' '_'];
end

[res,sGrid,sGridFirst]	= ParseArgs(varargin,13,4,[]);
sGridFirst				= unless(sGridFirst,sGrid);
sGrid					= repto(reshape(sGrid,1,[]),[1 2]);
sGridFirst				= repto(reshape(sGridFirst,1,[]),[1 2]);

%get the grid characters
	chrGrid			= reshape(chr(1:prod(sGrid)),sGrid(1),sGrid(2));
	chrGridFirst	= reshape(chr(1:prod(sGridFirst)),sGridFirst(1),sGridFirst(2));

boxS	= -90;
boxN	= 90;
boxW	= -180;
boxE	= 180;

gh	= char(zeros(1,res));
for r=1:res
	if r==1
		sGridCur	= sGridFirst;
		chrGridCur	= chrGridFirst;
	else
		sGridCur	= sGrid;
		chrGridCur	= chrGrid;
	end
	
	rngLat	= boxN-boxS;
	rngLng	= boxE-boxW;
	
	hCell	= rngLat/sGridCur(1);
	wCell	= rngLng/sGridCur(2);
	
	x	= min([floor(sGridCur(2)*(lng-boxW)/rngLng)+1 sGridCur(2)]);
	y	= min([floor(sGridCur(1)*(lat-boxS)/rngLat)+1 sGridCur(1)]);
	
	gh(r)	= chrGridCur(y,x);
	
	boxS	= boxS + hCell*(y-1);
	boxN	= boxS + hCell;
	boxW	= boxW + wCell*(x-1);
	boxE	= boxW + wCell;
end
