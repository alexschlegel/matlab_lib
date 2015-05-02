function [bSuccess,cPathWM] = FreeSurferMaskWM(cDirSubject,varargin)
% FreeSurferMaskWM
% 
% Description:	create binary white matter masks using segmentation data from
%				FreeSurfer
% 
% Syntax:	[bSuccess,cPathWM] = FreeSurferMaskWM(cDirSubject,<options>)
% 
% In:
% 	cDirSubject	- a subject's FreeSurfer directory, or a cell of directories
%	<options>:
%		output:		(<auto>) output file path(s)
%		cerebellum:	(true) true to include cerebellar white matter
%		grow:		(0) grow the mask by the specified number of pixels.  can be
%					negative.
%		force:		(false) true to force recalculation of the mask even if the
%					output already exists
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which masks were successfully
%				  created
%	cPathWM		- path/cell of paths to the white matter masks
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'		, []		, ...
		'cerebellum'	, true		, ...
		'grow'			, 0			, ...
		'force'			, true		, ...
		'cores'			, 1			, ...
		'silent'		, false		  ...
		);

if isempty(cDirSubject)
	bSuccess	= false(0);
	cPathWM	= [];
	return;
end

[cDirSubject,cPathWM,bNoCell,b]	= ForceCell(cDirSubject,opt.output);
[cDirSubject,cPathWM]				= FillSingletonArrays(cDirSubject,cPathWM);
cPathWM								= cellfun(@(f,d) unless(f,PathUnsplit(DirAppend(d,'mri'),'wm_mask','nii.gz')),cPathWM,cDirSubject,'UniformOutput',false);

nSubject							= numel(cDirSubject);
sSubject							= size(cDirSubject);

bNoCell	= bNoCell && nSubject==1;

if opt.force
	bProcess	= true(sSubject);
else
	bProcess	= ~FileExists(cPathWM);
end

bSuccess			= true(sSubject);
bSuccess(bProcess)	= MultiTask(@MaskOne,{cDirSubject(bProcess) cPathWM(bProcess)},...
						'description'	, 'Creating white matter masks'	, ...
						'uniformoutput'	, true							, ...
						'cores'			, opt.cores						, ...
						'silent'		, opt.silent					  ...
						);

if bNoCell
	cPathWM	= cPathWM{1};
end


%------------------------------------------------------------------------------%
function b = MaskOne(strDirSubject,strPathWM)
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
	%extract the white matter
		nii	= NIfTI.Read(strPathLabelNII);
		
		kWhite	= [2 41 86 155:158 159:162 219 223 250:255];
		if opt.cerebellum
			kWhite	= [kWhite 7 46];
		end
		
		nii.data	= ismember(nii.data,kWhite);
		
		NIfTI.Write(nii,strPathWM);
	%grow
		if opt.grow~=0
			b	= MRIMaskGrow(strPathWM,opt.grow,'output',strPathWM,'silent',opt.silent);
		end
end
%------------------------------------------------------------------------------%

end
