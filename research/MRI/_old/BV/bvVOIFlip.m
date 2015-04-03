function bvVOIFlip(voi,strPlane)
% bvVOIFlip
% 
% Description:	flip the coordinates of a VOI across the specified plane
% 
% Syntax:	voi = bvVOIFlip(voi,strPlane)
% 
% In:
% 	voi			- a VOI loaded with BVQXfile
%	strPlane	- a string specifying the plane across which to flip:
%					'saggital', 'coronal', or 'transverse'
% 
% Assumptions:	assumes the VOI coordinates are in Talairach space
% 
% Updated:	2009-06-16
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.

%get the coordinates to flip
	switch lower(strPlane)
		case 'saggital'		%talairach x
			kFlip	= 1;
		case 'coronal'		%talairach y
			kFlip	= 2;
		case 'transverse'	%talairach z
			kFlip	= 3;
		otherwise
			error(['"' strPlane '" is an invalid flip plane.']);
	end

%flip!
	nVOI	= voi.NrOfVOIs;
	for k=1:nVOI
		voi.VOI(k).Voxels(:,kFlip)	= -voi.VOI(k).Voxels(:,kFlip);
	end
