function [bSuccess,strPathMask,strName] = FreeSurferMask(strDirSubject,cLabel,varargin)
% FreeSurferMask
% 
% Description:	extract a mask from a subject's aparc.a2009s+aseg segmentation
%				volume
% 
% Syntax:	[bSuccess,strPathMask,strName] = FreeSurferMask(strDirSubject,cLabel,[strHemisphere]=<none>,<options>)
% 
% In:
%	strDirSubject	- the base FreeSurfer directory for the subject
%	cLabel			- a string or cell of strings specifying the structures to 
%					  extract and merge (see the aseg and a2009s labels in
%					  FreeSurferLabels).
%	[strHemisphere]	- if the structure has both left and right hemisphere
%					  components (e.g. 'Left-Amygdala'), you can specify only the
%					  name of the structure(s) in cLabel (e.g. 'Amygdala') and
%					  'lh' or 'rh' here
%	<options>:
%		name:		(<auto>) the name of the mask ('lh.' and 'rh.' are added)
%		crop:		(<no crop>) the fractional bounding box to crop from the
%					merged mask, or a cell of bounding boxes to crop before
%					merging the structures (see MRIMaskCrop)
%		xfm:		(<none>) the path to a transform matrix or warp if mask
%					should be transformed to another space
%		ref:		(<none>) the path to the transform's corresponding reference
%					volume
%		xfm_suffix:	(<auto>) the suffix to add to the transformed mask
%		outdir:		(<fs mask dir>) the output directory for the mask
%		output:		(<outdir>/<name>[<crop>][-<xfm_suffix>].nii.gz>) the output
%					path for the mask.  overrides <outdir>, <name>, and
%					<xfm_suffix>.
%		force:		(true) true to force creation of the mask even if the output
%					file already exists
%		forceprep:	(false) true to force preparatory processes (e.g. converting
%					aseg.mgz to NIfTI)
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- true if the mask was successfully created
%	strPathMask	- the path to the mask
%	strName		- the name given to the mask
% 
% Notes:	Crop directions: x:R->L y:S->I z:P->A
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bSuccess				= false;
[strPathMask,strName]	= deal([]);

[strHemisphere,opt]	= ParseArgs(varargin,[],...
						'name'			, []	, ...
						'crop'			, []	, ...
						'xfm'			, []	, ...
						'ref'			, []	, ...
						'xfm_suffix'	, []	, ...
						'outdir'		, []	, ...
						'output'		, []	, ...
						'force'			, true	, ...
						'forceprep'		, false	, ...
						'silent'		, false	  ...
						);

bCropBefore	= ~isempty(opt.crop) && iscell(opt.crop);
bCropAfter	= ~isempty(opt.crop) && ~bCropBefore;

cLabel	= ForceCell(cLabel);
szLabel	= size(cLabel);
nLabel	= numel(cLabel);

strDirSubject	= AddSlash(strDirSubject);
cDir			= DirSplit(strDirSubject);
strSubject		= cDir{end};
strDirBase		= DirUnsplit(cDir(1:end-1));
strDirMRI		= DirAppend(strDirSubject,'mri');
strDirMask		= DirAppend(strDirSubject,'mask');

%get the label info
	[cLabel,cAbb,kLabel,strName]	= FreeSurferLabels(cLabel,strHemisphere,'name',opt.name,'crop',opt.crop);
%output path
	if ~isempty(opt.output)
		strName		= PathGetFilePre(opt.output);
		strPathMask	= opt.output;
	else
		strDirOut	= unless(opt.outdir,strDirMask);
		CreateDirPath(strDirMask,'error',true);
		
		if isempty(opt.name) && bCropAfter
			cF		= num2cell(roundn(opt.crop,-2));
			strF	= ['(' join(cF(1,:),',') ';' join(cF(2,:),',') ')'];
			
			strName	= [strName '-' strF];
		end
		
		strPathMask	= PathUnsplit(strDirOut,strName,'nii.gz');
		
		if ~isempty(opt.xfm)
			strSuffix	= unless(opt.xfm_suffix,PathGetFilePre(opt.xfm));
			strPathMask	= PathAddSuffix(strPathMask,['-' strSuffix],'favor','nii.gz');
		end
	end

if opt.force || ~FileExists(strPathMask)
	%convert aparc.a2009s+aseg to NIfTI
		strPathSegMGZ	= PathUnsplit(strDirMRI,'aparc.a2009s+aseg','mgz');
		strPathSeg		= PathAddSuffix(strPathSegMGZ,'','nii.gz');
		if ~MRIConvert(strPathSegMGZ,strPathSeg,'force',opt.forceprep,'silent',opt.silent)
			status('Could not convert aparc.a2009s+aseg.mgz to NIfTI.','warning',true,'silent',opt.silent);
			return;
		end
	%load aseg
		niiSeg	= NIfTI.Read(strPathSeg);
	%OR the individual masks
		if bCropBefore
			niiMask			= niiSeg;
			niiMask.data	= false(size(niiMask.data));
			
			for kL=1:nLabel
				mskCur			= niiSeg.data==kLabel(kL);
				niiMask.data	= niiMask.data | MRIMaskCrop(mskCur,opt.crop{kL});
			end
		else
			niiMask			= niiSeg;
			niiMask.data	= ismember(niiMask.data,kLabel);
		end
		
		clear niiSeg;
	%crop the merged mask
		if bCropAfter
			niiMask.data	= MRIMaskCrop(niiMask.data,opt.crop);
		end
	%save the mask
		NIfTI.Write(niiMask,strPathMask);
	%transform the mask
		if ~isempty(opt.xfm) && ~FSLXFM(strPathMask,opt.xfm,opt.ref,...
									'output'	, strPathMask	, ...
									'mask'		, true			, ...
									'silent'	, opt.silent	  ...
								)
			status('Could not transform the mask to the output space.','warning',true,'silent',opt.silent);
			return;
		end
end

%success!
	bSuccess	= true;
