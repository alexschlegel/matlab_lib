function d = distLatLong(varargin)
% distLatLong
% 
% Description:	calculate the distance between two points on Earth
% 
% Syntax:	d = distLatLong(lat1,long1,lat2,long2) OR
%			d = distLatLong([lat1 long1],[lat2 long2])
% 
% In:
% 	lat1		- the latitude(s) of the first point(s), in degrees
%	long1		- the longitudes(s) of the first point(s), in degrees
%	lat2/long2	- the latitudes/longitudes of the second point(s)
% 
% Out:
% 	d	- the distance between the two (or corresponding) points, in meters
% 
% Updated: 2015-07-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch nargin
	case 4
		[lat1,long1,lat2,long2]	= deal(varargin{:});
	case 2
		lat1	= varargin{1}(:,1);
		long1	= varargin{1}(:,2);
		lat2	= varargin{2}(:,1);
		long2	= varargin{2}(:,2);
	otherwise
		error('invalid number of inputs');
end

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
