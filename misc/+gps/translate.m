function [lat,lng] = translate(lat,lng,v,varargin)
% gps.translate
% 
% Description:	translate along a vector from a (lat,lng) position, assuming the
%				translation is relatively small
% 
% Syntax:	[lat,lng] = gps.translate(lat,lng,v,<options>)
% 
% In:
% 	lat	- the base latitude
%	lng	- the base longitude
%	v	- the (NS, WE) vector along which to translate
%	<options>:
%		unit:	('m') the vector units.  one of:
%					'm': 	meters
%					'll':	latitude/longitude
% 
% Out:
% 	lat	- the new latitude
%	lng	- the new longitude
% 
% Updated: 2013-05-02
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent cEarth;

if isempty(cEarth)
	rEarth	= 6378100;
	cEarth	= 2*pi*rEarth;
end

opt	= ParseArgs(varargin,...
		'unit'	, 'm'	  ...
		);
opt.unit	= CheckInput(opt.unit,'unit',{'m'});

%convert v to lat/lng
switch opt.unit
	case 'm'
		C		= cEarth/360;
		v(1)	= v(1)/C;
		v(2)	= v(2)/(C*cos(lat));
	case 'll'
end

lat	= lat + v(1);
lng	= lng + v(2);
