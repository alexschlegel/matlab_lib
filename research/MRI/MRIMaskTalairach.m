function [nii,sLabel] = MRIMaskTalairach(cROI,varargin)
% MRIMaskTalairach
% 
% Description:	create a mask based on Talairach labels
% 
% Syntax:	[nii,sLabel] = MRIMaskTalairach(cROI,<options>)
% 
% In:
% 	cROI	- a string or cell of strings specifying Talairach ROIs to include
%			  in the mask (e.g. "Left Cerebrum Brodmann Area 45", "Right
%			  Cerebrum Frontal Lobe Gray Matter", "Right Brainstem Midbrain
%			  Thalamus Gray Matter Medial Geniculum Body", etc.)
%	<options>:
%		space:	('MNI152_T1_1mm') a NIfTI object in the desired output space,
%				or one of the following strings:
%					'MNI152_T1_1mm':	use the FSL 1mm MNI voxel space
%					'avg152T1':	use the FSL avg152T1 2mm voxel space
%					'FMRIB58_FA':	use the FMRIB58_FA 1mm voxel space
%		output:	(<none>) the output path for the mask.  either a file name
%				or the directory if the default file name should be used
%		slabel:	(<none>) the sLabel output from a previous call to
%				MRIMaskTalairach (to save time if multiple masks are being
%				created)
% 
% Out:
% 	nii		- if no output was selected, the mask NIfTI object.  otherwise the
%			  path to the output NIfTI object
%	sLabel	- a struct of info about Talairach labels, to save time for future
%			  calls to MRIMaskTalairach 
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'space'		, 'MNI152_T1_1mm'	, ...
		'output'	, []				, ...
		'slabel'	, []				  ...
		);

cROI	= ForceCell(cROI);
nROI	= numel(cROI);

%get the output space
	if ischar(opt.space)
		switch lower(opt.space)
			case {'mni152_t1_1mm','avg152t1','fmrib58_fa'}
				niiOutputSpace	= NIfTI.Read(FSLPathMNIAnatomical('type',opt.space)); 
			otherwise
				error(['"' opt.space '" is not a recognized output space.']);
		end
	else
		niiOutputSpace	= opt.space;
	end

%get the Talairach atlas info
	if isempty(opt.slabel)
	%load Talairach atlas info
		sLabel		= load('label_talairach');
		
		strPathAtlas	= FSLPathAtlas('talairach_1mm');
		sLabel.nii		= NIfTI.Read(strPathAtlas);
	else
	%Talairach atlas info was previously loaded
		sLabel	= opt.slabel;
	end
%get the labels to include in the mask
	cROIPath	= cellfun(@ParseROI,cROI,'UniformOutput',false);
	cLabel		= cellfun(@(p) GetFieldPath(sLabel.sLabelTalairach,p{:}),cROIPath,'UniformOutput',false);
	cLabel		= append(cLabel{:});
%construct the mask
	nii			= sLabel.nii;
	nii.data	= ismember(nii.data,cLabel);

%reorient the mask
	if ~NIfTI.SameSpace(nii,niiOutputSpace)
		nii	= NIfTI.Reorient(nii,niiOutputSpace);
	end
%get the output path
	bSave	= ~isempty(opt.output);
	if bSave && isdir(opt.output)
		strSuffix	= join(cellfun(@str2fieldname,cROI,'UniformOutput',false),'+');
		opt.output	= PathUnsplit(opt.output,['mask-talairach-' strSuffix],'nii.gz');
	end
%save the mask
	if bSave
		NIfTI.Write(nii,opt.output);
		nii	= opt.output;
	end

%------------------------------------------------------------------------------%
function cLabel = ParseROI(strLabel)
	strLabelOrig	= strLabel;
	cLabel			= {'any'; 'any'; 'any'; 'any'; 'all'};
	
	%check for valid labels
		strLabel	= lower(strLabel);
		for k=1:5
			cNodeCur	= sLabel.cNodeLabel{k};
			
			cMatch	= regexp(strLabel,cNodeCur);
			nMatch	= cellfun(@numel,cMatch);
			if sum(nMatch)>1
				break;
			elseif any(nMatch)
				kMatch		= find(nMatch);
				strMatch	= cNodeCur{kMatch}(3:end-2);
				lenMatch	= numel(strMatch);
				
				strLabel(cMatch{kMatch}:cMatch{kMatch}+lenMatch-1)	= [];
				
				cLabel{k}	= str2fieldname(strMatch);
			end
		end
	
	strLabel	= StringTrim(strLabel);
	
	if ~isempty(StringTrim(strLabel))
		error(['"' tostring(strLabelOrig) '" could not be parsed.']);
	end
end
%------------------------------------------------------------------------------%

end
