function [p,m] = MRIMaskPosition(strPathMask,varargin)
% MRIMaskPosition
% 
% Description:	calculate the center of mass of a NIfTI mask
% 
% Syntax:	[p,m] = MRIMaskPosition(strPathMask,<options>)
% 
% In:
% 	strPathMask	- the path to the mask file
%	<options>:
%		force:	(true) true to recalculate the mask position even if the stored
%				position text file already exists
% 
% Out:
% 	p	- the mask's center of mass, in standard NIfTI space (LR, PA, IS), or
%		  [NaN NaN NaN] if the mask doesn't exist
%	m	- the mass (i.e. number of voxels) of the mask, or NaN if the mask
%		  doesn't exist
% 
% Updated: 2015-12-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'force'		, true	  ...
		);

%store the position in a text file for quicker calculation next time
	strPathPos	= PathAddSuffix(strPathMask,'','pos','favor','nii.gz');

if ~opt.force && FileExists(strPathPos)
%just load the previously calculated position
	a	= str2array(fget(strPathPos));
	p	= a(1:3);
	m	= a(4);
elseif FileExists(strPathMask)
%load the NIfTI and calculate the center of mass
	%load
		nii			= NIfTI.Read(strPathMask);
		nii.data	= double(nii.data);
	%find non-zero values
		kMask		= find(nii.data~=0 & ~isnan(nii.data));
		nMask		= numel(kMask);
		[kX,kY,kZ]	= ind2sub(size(nii.data),kMask);
	%convert to standard NIfTI space
		p	= nii.hdr.mat*[kX kY kZ ones(nMask,1)]';
		p	= p(1:3,:)';
	%get the weighted mean of the mask positions
		w	= repmat(nii.data(kMask),[1 3]);
		m	= sum(nii.data(kMask));
		p	= sum(p.*w,1)./m;
	%save the position for future calls
		fput(array2str([p m]),strPathPos);
else
	p	= NaN(1,3);
	m	= NaN;
end
