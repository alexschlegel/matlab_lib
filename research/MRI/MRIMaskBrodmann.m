function nii = MRIMaskBrodmann(kArea,varargin)
% MRIMaskBrodmann
% 
% Description:	create a NIfTI Brodmann mask in MNI space
% 
% Syntax:	nii = MRIMaskBrodmann(kArea,<options>)
% 
% In:
% 	kArea	- an array of Brodmann areas to include in the mask
%	<options>:
%		hemisphere:	('both') 'left', 'right', or 'both' to specify which
%					hemispheres to include
%		fraction:	([0 0 0; 1 1 1]) a 2x3 matrix specifying which part of the
%					Brodmann ROI should be kept.  1st, 2nd, and 3rd columns
%					refer to LR, PA, and IS directions.  Top row is the starting
%					position as a fraction of the ROI extent; bottom row is the
%					ending position.  e.g. [0 0 0; 1 1/3 1] keeps the posterior
%					third of the ROI.
%		space:		('MNI152_T1_1mm') a NIfTI object in the desired output space,
%					or an input to FSLPathMNIAnatomical
%		input:		('mricron') one of the following to specify the source
%					template to use for extracting Brodmann areas:
%						'mricron':	use the MRIcron Brodmann template
%						'fsl_talairach':	use the Brodmann labels from FSL's
%							Talairach template stored in MNI space
%						strPathTemplate: the path to a Brodmann template (a 3D
%							NIfTI file storing Brodmann labels)
%						nii: a 3D NIfTI object loaded with NIfTI.Read and storing
%							Brodmann labels
%		output:		(<none>) the output path for the mask.  either a file name
%					or the directory if the default file name should be used
% 
% Out:
% 	nii	- if no output was selected, the mask NIfTI object.  otherwise the path
%		  to the output NIfTI object
%
% Assumptions:	assumes the input template is not aligned obliquely
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'hemisphere'	, 'both'			, ...
		'fraction'		, [0 0 0; 1 1 1]	, ...
		'space'			, 'MNI152_T1_1mm'	, ...
		'input'			, 'mricron'			, ...
		'output'		, []				  ...
		);

%get the output space
	if ischar(opt.space)
		strPathMNI	= FSLPathMNIAnatomical('type',opt.space);
		if ~isempty(strPathMNI)
			niiOutputSpace	= NIfTI.Read(strPathMNI);
		else
			error(['"' opt.space '" is not a recognized output space.']);
		end
	else
		niiOutputSpace	= opt.space;
	end

%get the Brodmann template
	bFSLTalairach	= false;
	switch class(opt.input)
		case 'char'
			switch lower(opt.input)
				case 'fsl_talairach'
					strPathFSLMNI	= FSLPathMNIAnatomical('type','MNI152_T1_1mm');
					niiBA			= NIfTI.Read(strPathFSLMNI);
					bFSLTalairach	= true;
				case 'mricron'
					strPathMRIcronBA	= PathUnsplit(DirAppend(GetDirMRIcron,'templates'),'brodmann','nii.gz');
					niiBA				= NIfTI.Read(strPathMRIcronBA);
				otherwise
					if FileExists(opt.input)
						niiBA	= NIfTI.Read(opt.input);
					else
						error('Specified Brodmann template is not recognized.');
					end
			end
		case 'struct'
			niiBA	= opt.input;
		otherwise
			error('Specified Brodmann template is not recognized.');
	end
%get the coordinate directions
	mOrient		= NIfTI.ImageGridOrientation(niiBA);
	kDirection	= arrayfun(@(x) find(mOrient(:,x)),1:3);
	dDirection	= arrayfun(@(x,y) mOrient(x,y),kDirection,1:3);
	
	%coordinate bounds
		sz		= size(niiBA.data);
		kBound	= arrayfun(@(x) 1:x,sz,'UniformOutput',false);
%create the mask
	if bFSLTalairach
		cArea	= arrayfun(@(k) ['Brodmann Area ' num2str(k)],kArea,'UniformOutput',false);
		nii		= MRIMaskTalairach(cArea,'space',niiBA);
	else
		nii			= niiBA;
		nii.data	= ismember(niiBA.data,kArea);
	end
%keep the hemisphere(s) of interest
	%LR indices
		kLR		= kDirection(1);
		dLR		= dDirection(1);
		kN		= sz(kLR);
		kCutoff	= kN/2;
		k		= kBound;
		if dLR>0
			kL	= 1:floor(kCutoff);
			kR	= ceil(kCutoff)+1:kN;
		else
			kL	= ceil(kCutoff)+1:kN;
			kR	= 1:floor(kCutoff);
		end
	
	switch lower(opt.hemisphere)
		case 'left'
			k{kLR}			= kR;
			nii.data(k{:})	= 0;
			
			strHemi			= '-left';
		case 'right'
			k{kLR}			= kL;
			nii.data(k{:})	= 0;
			
			strHemi			= '-right';
		case 'both'
			strHemi			= '';
		otherwise
			error(['"' tostring(opt.hemisphere) '" is not a valid hemisphere selection.']);
		end
%keep the fraction of interest
	strFraction	= '';
	cDirection	= {'lr','pa','is'};
	if ~isequal(opt.fraction,[0 0 0; 1 1 1])
		kMask				= find(nii.data);
		[xMask,yMask,zMask]	= ind2sub(sz,kMask);
		
		roiBound	= 	[
							min(xMask) max(xMask)
							min(yMask) max(yMask)
							min(zMask) max(zMask)
						];
		
		for kD=1:3
			if range(opt.fraction(:,kD))~=1
				k	= kBound;
				
				kDCur	= kDirection(kD);
				
				f	= conditional(dDirection(kD)>0,opt.fraction(:,kD),1-opt.fraction(:,kD));
				
				d	= roiBound(kDCur,2) - roiBound(kDCur,1);
				k1	= floor(roiBound(kDCur,1)+d*f(1));
				k2	= floor(roiBound(kDCur,1)+d*f(2));
				
				kMin	= min(k1,k2);
				kMax	= max(k1,k2);
				
				k{kDCur}	= [1:kMin-1 kMax+1:max(k{kDCur})];
				
				strFraction	= [strFraction '-' cDirection{kD} Frac2String(opt.fraction(1,kD)) 'to' Frac2String(opt.fraction(2,kD))];
				
				nii.data(k{:})	= 0;
			end
		end
	end
%reorient the mask
	if ~NIfTI.SameSpace(nii,niiOutputSpace)
		nii	= NIfTI.Reorient(nii,niiOutputSpace);
	end
%get the output path
	bSave	= ~isempty(opt.output);
	if bSave && isdir(opt.output)
		opt.output	= PathUnsplit(opt.output,['mask-brodmann-' join(kArea,'_') strHemi strFraction],'nii.gz');
	end
%save the mask
	if bSave
		NIfTI.Write(nii,opt.output);
		nii	= opt.output;
	end

%------------------------------------------------------------------------------%
function str = Frac2String(x)
	str	= strrep(num2str(roundn(x,-2)),'.','');
%------------------------------------------------------------------------------%
