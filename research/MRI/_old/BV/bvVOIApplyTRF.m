function bvVOIApplyTRF(voi,trf)
% bvVOIApplyTRF
% 
% Description:	apply a TRF to a VOI.  As of version 0.7, BVQXtools'
%				voi.ApplyTrf has a bug (line 98 if voi_ApplyTrf.m) that makes it
%				only work with VOIs that have a single cluster.
% 
% Syntax:	bvVOIApplyTRF(voi,trf)
% 
% In:
% 	voi	- a VOI loaded with BVQXfile
%	trf	- a TRF loaded with BVQXfile
% 
% Updated:	2009-06-16
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.

%initialize a temporary VOI
	voiT			= BVQXfile('new:voi');
	voiT.NrOfVOIs	= 1;
	voiT.VOI		= struct('Name','Temp','Color',[255 0 0],'NoOfVoxels',0,'Voxels',zeros(0,3));
%apply the TRF to each VOI in voi individually
	nVOI	= voi.NrOfVOIs;
	for k=1:nVOI
		%transfer the coordinates
			voiT.VOI.NoOfVoxels	= voi.VOI(k).NrOfVoxels;
			voiT.VOI.Voxels		= voi.VOI(k).Voxels;
		%apply the transformation
			voiT.ApplyTrf(trf);
		%transfer back the coordinates
			voi.VOI(k).Voxels	= voiT.VOI.Voxels;
	end
	
%clear the temporary VOI
	voiT.ClearObject;
