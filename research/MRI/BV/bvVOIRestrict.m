function bvVOIRestrict(voi,varargin)
% bvVOIRestrict
% 
% Description:	restrict the voxels in a VOI to those within a specified box
% 
% Syntax:	bvVOIRestrict(voi,[xMin],[xMax],[yMin],[yMax],[zMin],[zMax])
% 
% In:
% 	[xyz][Max/Min]	- if specified, defines a box boundary, in Talairach
%					  coordinates.  voxels aren't restricted for unspecified
%					  boundaries.
% 
% Updated:	2009-08-13
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
[xMin,xMax,yMin,yMax,zMin,zMax]	= ParseArgs(varargin,-inf,inf,-inf,inf,-inf,inf);

nVOI	= voi.NrOfVOIs;
for kVOI=1:nVOI
	bXLess	= voi.VOI(kVOI).Voxels(:,1) < xMin;
	bXMore	= voi.VOI(kVOI).Voxels(:,1) > xMax;
	bYLess	= voi.VOI(kVOI).Voxels(:,2) < yMin;
	bYMore	= voi.VOI(kVOI).Voxels(:,2) > yMax;
	bZLess	= voi.VOI(kVOI).Voxels(:,3) < zMin;
	bZMore	= voi.VOI(kVOI).Voxels(:,3) > zMax;
	
	bIn	= ~(bXLess | bXMore | bYLess | bYMore | bZLess | bZMore);
	
	voi.VOI(kVOI).Voxels		= voi.VOI(kVOI).Voxels(bIn,:);
	voi.VOI(kVOI).NrOfVoxels	= size(voi.VOI(kVOI).Voxels,1);
end
