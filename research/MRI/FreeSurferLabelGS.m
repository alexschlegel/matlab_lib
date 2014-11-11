function [bSuccess,strPathLabel,strName,strPathVol] = FreeSurferLabelGS(strDirSubject,strHemisphere,cGS,varargin)
% FreeSurferLabelGS
% 
% Description:	extract labels from FreeSurfer's aparc a2009s gyrus/sulcus
%				parcellation
% 
% Syntax:	[bSuccess,strPathLabel,strName,strPathVol] = FreeSurferLabelGS(strDirSubject,strHemisphere,cGS,<options>)
% 
% In:
%	strDirSubject	- the base FreeSurfer directory for the subject whose labels
%					  will be extracted
%	strHemisphere	- the hemisphere to use for the label.  either 'lh' or 'rh'
% 	cGS				- a string or cell of strings specifying the structures to 
%					  extract and merge (see the labels in the subject's
%					  label/aparc.annot.a2009s.ctab file)
%	<options>:
%		name:		(<auto>) the name of the label
%		crop:		(<no crop>) the fractional bounding box to crop from the
%					merged label, or a cell of bounding boxes to crop before
%					merging (see FreeSurferLabelCrop)
%		xfm:		(<none>) the path to a transform matrix or warp if the binary
%					mask volume should be transformed to another space
%		ref:		(<none>) the path to the transform's corresponding reference
%					volume
%		xfm_suffix:	(<auto>) the suffix to add to the transformed volume
%		xfm_outdir:	(<same as label>) the output directory for the transformed
%					volume
%		output:		(<<hemi>.<name>[<crop>].label in subject's label directory>)
%					the output path for the label.  overrides <name>.
%		force:		(true) true to force creation of the label even if the output
%					file already exists
%		silent:		(false) true to suppress status messages
% 
% Out:
%	bSuccess		- true if the labels were successfully extracted and merged
%	strPathLabel	- the path to the label file
%	strName			- the name given to the label
%	strPathVol		- the path to the binarized NIfTI version of the label
% 
% Updated: 2011-03-03
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bSuccess							= false;
[strPathLabel,strName,strPathVol]	= deal([]);

opt	= ParseArgs(varargin,...
		'name'			, []	, ...
		'crop'			, []	, ...
		'xfm'			, []	, ...
		'ref'			, []	, ...
		'xfm_suffix'	, []	, ...
		'xfm_outdir'	, []	, ...
		'output'		, []	, ...
		'force'			, true	, ...
		'silent'		, false	  ...
		);

bCropBefore	= ~isempty(opt.crop) && iscell(opt.crop);
bCropAfter	= ~isempty(opt.crop) && ~bCropBefore;

strHemisphere	= lower(strHemisphere);
if ~ismember(strHemisphere,{'lh','rh'})
	error(['"' tostring(strHemisphere) '" is not a valid hemisphere.']);
end

cGS	= ForceCell(cGS);
nGS	= numel(cGS);

strDirSubject	= AddSlash(strDirSubject);
cDir			= DirSplit(strDirSubject);
strSubject		= cDir{end};
strDirBase		= DirUnsplit(cDir(1:end-1));
strDirLabel		= DirAppend(strDirSubject,'label');

%get the label info
	sLabel	= FreeSurferLabels(strDirSubject);
	sLabel	= sLabel.a2009s;
%get the indices of the labels to extract
	[bLabel,kLabel]	= ismember(lower(cGS),lower(sLabel.label));
	if ~all(bLabel)
		error(['The following are not valid aparc labels:' 10 join(cGS(~bLabel),10)]);
	end
%output path
	if ~isempty(opt.output)
		strName			= PathGetFilePre(opt.output);
		strPathLabel	= opt.output;
	else
		strName	= unless(opt.name,join(sLabel.abb(kLabel),'_'));
		
		if ~isempty(opt.name) || isempty(opt.crop)
			strPathLabel	= PathUnsplit(strDirLabel,[strHemisphere '.' strName],'label');
		else
			cF			= num2cell(roundn(opt.crop,-2));
			strF		= ['(' join(cF(1,:),',') ';' join(cF(2,:),',') ')'];
			
			strPathLabel	= PathUnsplit(strDirLabel,[strHemisphere '.' strName '-' strF],'label');
		end
	end

if opt.force || ~FileExists(strPathLabel)
	%convert the annotations to labels
		bExtract	= ~all(FileExists(sLabel.path.(strHemisphere)(kLabel)));
		if bExtract && CallProcess('mri_annotation2label',{...
							'--subject'		, strSubject			, ...
							'--hemi'		, strHemisphere			, ...
							'--annotation'	, 'aparc.a2009s'		, ...
							'--outdir'		, ['"' strDirLabel '"']	, ...
							'--sd'			, ['"' strDirBase '"']	  ...
							},...
							'silent'	, opt.silent				  ...
							)
			status(['Could not extract labels for subject ' strSubject '.'],'warning',true,'silent',opt.silent);
			return;
		end
	%crop the unmerged labels
		cPathLabel	= sLabel.path.(strHemisphere)(kLabel);
		
		if bCropBefore
			[b,cPathLabel]	= cellfun(@FreeSurferLabelCrop,cPathLabel,opt.crop,'UniformOutput',false);
			
			if ~all(cell2mat(b))
				status('Could not crop the unmerged labels.','warning',true,'silent',opt.silent);
				return;
			end
		end
	%merge the specified labels
		if nGS>1
			strLabels	= ['-i "' join(cPathLabel,'" -i "') '"'];
			
			if RunBashScript(['mri_mergelabels ' strLabels ' -o "' strPathLabel '"'],'silent',opt.silent)
				status('Could not merge the specified labels.','warning',true,'silent',opt.silent);
				return;
			end
		else
			%delete the output file if it already exists
				if FileExists(strPathLabel)
					delete(strPathLabel);
				end
			
			if ~copyfile(cPathLabel{1},strPathLabel) && ~FileExists(strPathLabel)
				status(['Could not copy the label file ' cPathLabel{1} '.'],'warning',true,'silent',opt.silent);
				return
			end
		end
	%crop the merged label
		if bCropAfter && ~FreeSurferLabelCrop(strPathLabel,opt.crop,'output',strPathLabel);
			status('Could not crop the merged labels.','warning',true,'silent',opt.silent);
			return;
		end
end
%save a binarized version of each label
	[b,strPathVol]	= FreeSurferLabel2Vol(strPathLabel,'force',opt.force,'silent',opt.silent);
	if ~b
		status('Could not convert the label to NIfTI.','warning',true,'silent',opt.silent);
		return;
	end
%transform the binary mask volume
	if ~isempty(opt.xfm)
		[b,strPathVol]	= FSLXFM(strPathVol,opt.xfm,opt.ref,'outdir',opt.xfm_outdir,'suffix',opt.xfm_suffix,'mask',true,'force',opt.force,'silent',opt.silent);
		if ~b
			status('Could not transform the binary label volume to the output space.','warning',true,'silent',opt.silent);
			return;
		end
	end
	

%success!
	bSuccess	= true;
