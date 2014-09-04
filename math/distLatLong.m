function d = distLatLong(lat1,long1,lat2,long2)
% distLatLong
% 
% Description:	calculate the distance between two points on Earth
% 
% Syntax:	d = distLatLong(lat1,long1,lat2,long2)
% 
% In:
% 	lat1		- the latitude(s) of the first point(s), in degrees
%	long1		- the longitudes(s) of the first point(s), in degrees
%	lat2/long2	- the latitudes/longitudes of the second point(s)
% 
% Out:
% 	d	- the distance between the two (or corresponding) points, in meters
% 
% Updated: 2010-05-11
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

rEarth	= 6378137;

%fill singleton values
	[lat1,long1,lat2,long2]	= FillSingletonArrays(lat1,long1,lat2,long2);
%calculate the distance using the Haversine formula
	lat1	= lat1*pi/180;
	long1	= long1*pi/180;
	lat2	= lat2*pi/180;
	long2	= long2*pi/180;
	
	a	= sin((lat2-lat1)/2).^2+cos(lat1).*cos(lat2).*sin((long2-long1)/2).^2;
	d	= 2.*rEarth.*atan2(sqrt(a),sqrt(1-a));
	