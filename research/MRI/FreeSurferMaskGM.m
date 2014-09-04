function [bSuccess,cPathGM] = FreeSurferMaskGM(cDirSubject,varargin)
% FreeSurferMaskGM
% 
% Description:	create binary gray matter masks using segmentation data from
%				FreeSurfer
% 
% Syntax:	[bSuccess,cPathGM] = FreeSurferMaskGM(cDirSubject,<options>)
% 
% In:
% 	cDirSubject	- a subject's FreeSurfer directory, or a cell of directories
%	<options>:
%		output:		(<auto>) output file path(s)
%		cerebellum:	(true) true to include cerebellar gray matter
%		grow:		(0) grow the mask by the specified number of pixels.  can be
%					negative.
%		force:		(false) true to force recalculation of the mask even if the
%					output already exists
%		nthread:	(1) numbers of threads to use for the computations
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which masks were successfully
%				  created
%	cPathGM		- path/cell of paths to the gray matter masks
% 
% Updated: 2012-07-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'output'		, []		, ...
		'cerebellum'	, true		, ...
		'grow'			, 0			, ...
		'force'			, true		, ...
		'nthread'		, 1			, ...
		'silent'		, false		  ...
		);

if isempty(cDirSubject)
	bSuccess	= false(0);
	cPathGM	= [];
	return;
end

[cDirSubject,cPathGM,bNoCell,b]	= ForceCell(cDirSubject,opt.output);
[cDirSubject,cPathGM]				= FillSingletonArrays(cDirSubject,cPathGM);
cPathGM								= cellfun(@(f,d) unless(f,PathUnsplit(DirAppend(d,'mri'),'gm_mask','nii.gz')),cPathGM,cDirSubject,'UniformOutput',false);

nSubject							= numel(cDirSubject);
sSubject							= size(cDirSubject);

bNoCell	= bNoCell && nSubject==1;

if opt.force
	bProcess	= true(sSubject);
else
	bProcess	= ~FileExists(cPathGM);
end

bSuccess			= true(sSubject);
bSuccess(bProcess)	= MultiTask(@MaskOne,{cDirSubject(bProcess) cPathGM(bProcess)},...
						'description'	, 'Creating gray matter masks'	, ...
						'uniformoutput'	, true							, ...
						'nthread'		, opt.nthread					, ...
						'silent'		, opt.silent					  ...
						);

if bNoCell
	cPathGM	= cPathGM{1};
end


%------------------------------------------------------------------------------%
function b = MaskOne(strDirSubject,strPathGM)
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
	%extract the gray matter
		nii	= NIfTIRead(strPathLabelNII);
		
		if opt.cerebellum
			nii.data	= nii.data>=11000 | ismember(nii.data,[8 47]);
		else
			nii.data	= nii.data>=11000;
		end
		
		NIfTIWrite(nii,strPathGM);
	%grow
		if opt.grow~=0
			b	= MRIMaskGrow(strPathGM,opt.grow,'output',strPathGM,'silent',opt.silent);
		end
end
%------------------------------------------------------------------------------%

end
