function stl = FreeSurferSTL(strDirSubject,cLabel,varargin)
% FreeSurferSTL
% 
% Description:	convert a set of labels from a subject's aparc.a2009s+aseg
%				segmentation volume into an STL struct
% 
% Syntax:	stl = FreeSurferSTL(strDirSubject,cLabel,[isoval]=<auto>,<options>)
% 
% In:
% 	strDirSubject	- the base FreeSurfer directory for the subject
% 	cLabel			- a string or cell of strings specifying the structures to 
% 					  extract and merge (see the aseg and a2009s labels in
% 					  FreeSurferLabels).
%	[isoval]		- the isosurface value
%	<options>:
%		name:		(<auto>) the STL name
%		crop:		(<no crop>) the fractional bounding box to crop from the
%					merged mask, or a cell of bounding boxes to crop before
%					merging the structures (see MRIMaskCrop)
%		resample:	(1) the resampling factor
% 
% Out:
% 	stl	- the STL struct
% 
% Updated: 2015-06-15
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
stl	= [];

[isoval,opt]	= ParseArgs(varargin,[],...
					'name'		, []	, ...
					'crop'		, []	, ...
					'resample'	, 1		  ...
					);

bCropBefore	= ~isempty(opt.crop) && iscell(opt.crop);
bCropAfter	= ~isempty(opt.crop) && ~bCropBefore;

cLabel	= ForceCell(cLabel);
szLabel	= size(cLabel);
nLabel	= numel(cLabel);

strDirMRI		= DirAppend(strDirSubject,'mri');

%get the label info
	[cLabel,cAbb,kLabel]	= FreeSurferLabels(cLabel);
%convert aparc.a2009s+aseg to NIfTI
	strPathSegMGZ	= PathUnsplit(strDirMRI,'aparc.a2009s+aseg','mgz');
	strPathSeg		= PathAddSuffix(strPathSegMGZ,'','nii.gz');
	if ~MRIConvert(strPathSegMGZ,strPathSeg,'force',false)
		status('Could not convert aparc.a2009s+aseg.mgz to NIfTI.','warning',true);
		return;
	end
%convert the brain to NIfTI
	strPathBrainMGZ	= PathUnsplit(strDirMRI,'brain','mgz');
	strPathBrain	= PathAddSuffix(strPathBrainMGZ,'','nii.gz');
	if ~MRIConvert(strPathBrainMGZ,strPathBrain,'force',false)
		status('Could not convert brain.mgz to NIfTI.','warning',true);
		return;
	end
%load aseg and brain
	niiSeg	= NIfTI.Read(strPathSeg);
	nii		= NIfTI.Read(strPathBrain);
	
	M	= FreeSurferSurfaceMAT(strPathBrain);
%OR the individual masks
	if bCropBefore
		bKeep	= false(size(niiSeg.data));
		
		for kL=1:nLabel
			mskCur	= niiSeg.data==kLabel(kL);
			bKeep	= bKeep | MRIMaskCrop(mskCur,opt.crop{kL});
		end
	else
		bKeep	= ismember(niiSeg.data,kLabel);
	end
	
	clear niiSeg;
%crop the merged mask
	if bCropAfter
		bKeep	= MRIMaskCrop(bKeep,opt.crop);
	end
%keep only the specified mask
	nii.data(~bKeep)	= 0;
%optionally resample
	if opt.resample~=1
		[sX,sY,sZ]	= size(nii.data);
		
		[xi,yi,zi]	= varfun(@(s) GetInterval(1,s,round(s*opt.resample)),sX,sY,sZ);
		[xi,yi,zi]	= meshgrid(xi,yi,zi);
		
		nii.data	= interp3(nii.data,xi,yi,zi,'linear');
		
		M(1:3,1:3)	= M(1:3,1:3)/opt.resample;
	end
%STL!
	stl	= NIfTI.STL(nii,...
			'isoval'	, isoval	, ...
			'mat'		, M			  ...
			);
%name?
	if ~isempty(opt.name)
		nHeader		= numel(stl.Header);
		stl.Header	= StringFill(opt.name,nHeader,' ','right');
	end
