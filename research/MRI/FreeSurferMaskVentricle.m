function [bSuccess,cPathVentricle] = FreeSurferMaskVentricle(cDirSubject,varargin)
% FreeSurferMaskVentricle
% 
% Description:	create binary ventricle masks using segmentation data from
%				FreeSurfer
% 
% Syntax:	[bSuccess,cPathVentricle] = FreeSurferMaskVentricle(cDirSubject,<options>)
% 
% In:
% 	cDirSubject	- a subject's FreeSurfer directory, or a cell of directories
%	<options>:
%		output:	(<auto>) output file path(s)
%		grow:	(0) grow the mask by the specified number of pixels.  can be
%				negative.
%		force:	(false) true to force recalculation of the mask even if the
%				output already exists
%		cores:	(1) the number of processor cores to use
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	bSuccess		- a logical array indicating which masks were successfully
%					  created
%	cPathVentricle	- path/cell of paths to the ventricle masks
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'	, []		, ...
		'grow'		, 0			, ...
		'force'		, true		, ...
		'cores'		, 1			, ...
		'silent'	, false		  ...
		);

if isempty(cDirSubject)
	bSuccess		= false(0);
	cPathVentricle	= [];
	return;
end

[cDirSubject,cPathVentricle,bNoCell,b]	= ForceCell(cDirSubject,opt.output);
[cDirSubject,cPathVentricle]			= FillSingletonArrays(cDirSubject,cPathVentricle);
cPathVentricle							= cellfun(@(f,d) unless(f,PathUnsplit(DirAppend(d,'mri'),'ventricle_mask','nii.gz')),cPathVentricle,cDirSubject,'UniformOutput',false);

nSubject							= numel(cDirSubject);
sSubject							= size(cDirSubject);

bNoCell	= bNoCell && nSubject==1;

if opt.force
	bProcess	= true(sSubject);
else
	bProcess	= ~FileExists(cPathVentricle);
end

bSuccess			= true(sSubject);
bSuccess(bProcess)	= MultiTask(@MaskOne,{cDirSubject(bProcess) cPathVentricle(bProcess)},...
						'description'	, 'Creating ventricle masks'	, ...
						'uniformoutput'	, true							, ...
						'cores'			, opt.cores						, ...
						'silent'		, opt.silent					  ...
						);

if bNoCell
	cPathVentricle	= cPathVentricle{1};
end


%------------------------------------------------------------------------------%
function b = MaskOne(strDirSubject,strPathVentricle)
	b	= false;
	
	%convert the label volume to NIfTI
		strDirMRI		= DirAppend(strDirSubject,'mri');
		strPathLabel	= PathUnsplit(strDirMRI,'aparc.a2009s+aseg','mgz');
		strPathLabelNII	= PathAddSuffix(strPathLabel,'','nii.gz');
		
		if ~FileExists(strPathLabel)
			return;
		end
		
		b	= MRIConvert(strPathLabel,strPathLabelNII,'force',false);
		
		if ~b
			return;
		end
	%extract the ventricles
		nii	= NIfTI.Read(strPathLabelNII);
		
		kVentricle	= [4 5 14 15 43 44 72 75 76 213];
		nii.data	= ismember(nii.data,kVentricle);
		
		NIfTI.Write(nii,strPathVentricle);
	%grow
		if opt.grow~=0
			b	= MRIMaskGrow(strPathVentricle,opt.grow,'output',strPathVentricle,'silent',opt.silent);
		end
end
%------------------------------------------------------------------------------%

end
