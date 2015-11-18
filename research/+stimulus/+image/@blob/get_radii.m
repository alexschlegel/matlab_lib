function r = get_radii(obj)
% stimulus.image.blob.get_radii
% 
% Description:	get control point radii
% 
% Syntax: r = obj.get_radii()
% 
% Out:
%	r	- the radii
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
r	= normalize(rand(obj.param.n,1),'min',obj.param.rmin,'max',obj.param.rmax);
