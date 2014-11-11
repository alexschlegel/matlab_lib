function bvVOICompress(voi,varargin)
% bvVOICompress
% 
% Description:	compresses all points in the VOI into one cluster
% 
% Syntax:	bvVOICompress(voi,<options>)
% 
% In:
% 	voi	- a VOI loaded with BVQXfile
%	<options>:
%		'name':	('compressed') the name of the new VOI
% 
% Updated:	2009-03-11
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'name'	, 'compressed'	  ...
		);

nCluster	= numel(voi.VOI);
%append all points.  for some reason the [s.a.b] notation isn't working for
%appending all the .b's together.  BVQXfile must be doing something weird.
	vox	= zeros(0,3);
	for kC=1:nCluster
		vox	= [vox; voi.VOI(kC).Voxels];
	end
%keep only the unique ones
	vox	= unique(vox,'rows');
	
%construct the new VOI
	voi.NrOfVOIs		= 1;
	voi.VOI				= voi.VOI(1);
	voi.VOI.Name		= opt.name;
	voi.VOI.NrOfVoxels	= size(vox,1);
	voi.VOI.Voxels		= vox;
