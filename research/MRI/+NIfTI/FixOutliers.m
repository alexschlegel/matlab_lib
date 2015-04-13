function s = FixOutliers(strPathNII,varargin)
% NIfTI.FixOutliers
% 
% Description:	fix outliers in NIfTI data. for 3D data, outliers are set to the
%				mean of all non-outlier voxels. for 4D data, outliers are set to
%				the mean of the non-outlier samples of the same voxel. 
% 
% Syntax:	s = NIfTI.FixOutliers(strPathNII,<options>)
% 
% In:
% 	strPathNII	- the path to a NIfTI file
%	<options>:
%		cutoff:	(8) the minimum number of standard deviations away from the mean
%				non-zero magnitude for a value to be considered an outlier
%		output:	(<same>) the output file path
% 
% Out:
% 	s	- a struct of info
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= struct;

%parse the inputs
	opt	= ParseArgs(varargin,...
			'cutoff'	, 8		, ...
			'output'	, []	  ...
			);
	
	strPathOut	= unless(opt.output,strPathNII);

%load the NIfTI data
	nii	= NIfTI.Read(strPathNII);
	sz	= size(nii.data);
	nd	= numel(sz);

%get the mean and standard deviation of non-zero magnitudes
	x	= nii.data~=0;
	x	= abs(double(nii.data(x)));
	m	= nanmean(x);
	sd	= nanstd(x);
	clear x;

%get the outliers
	bOutlier	= abs(nii.data - m) > opt.cutoff*sd;
	s.nOutlier	= sum(bOutlier(:));
	clear m sd;

if s.nOutlier>0
	%calculate the non-outlier means
		switch nd
			case 3
				m	= nanmean(double(nii.data(~bOutlier)));
			case 4
				nT	= sz(4);
				n	= sum(~bOutlier,4);
				m	= sum(double(nii.data).*(1-bOutlier),4);
				m	= repmat(m./n,[1 1 1 nT]);
		end
	%replace the outliers with the mean
		nii.data(bOutlier)	= m(bOutlier);
	
	%save the data
		NIfTI.Write(nii,strPathOut);
end
