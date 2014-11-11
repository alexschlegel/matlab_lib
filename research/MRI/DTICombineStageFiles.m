function [cPathCum,cPathExclude,cPathAdd,cPathDel] = DTICombineStageFiles(strDirCombined,kStage,varargin)
% DTICombineStageFiles
% 
% Description:	return the files involved with each stage of DTICombine
%				processing (see DTICombineGetStage)
% 
% Syntax:	[cPathCum,cPathAdd,cPathDel] = DTICombineStageFiles(strDirCombined,kStage,<options>)
% 
% In:
% 	strDirCombined	- the combined session directory
%	kStage			- the stage of interest
%	<options>:
%		nfibres:	(2) the number of fibers specified in the bedpostx advanced
%					options
% 
% Out:
% 	cPathCum		- a cell of paths to files that should exist after the
%					  specified stage is complete
%	cPathExclude	- a cell of paths that should not exist at the specified
%					  stage
%	cPathAdd		- a cell of paths to files that were added by the specified
%					  stage
%	cPathDel		- a cell of paths to files that were deleted by the
%					  specified stage
% 
% Updated: 2011-02-17
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'nfibres'	, 2	  ...
		);

kStageAll	= 0:9;

strDirCombined	= PathGetDir(strDirCombined);

%get the cumulative file state of the specified stage
	kkStage	= find(kStage==kStageAll,1);
	
	[cPathCum,cPathExclude,cPathAdd,cPathDel]	= deal({});
	
	for kS=1:kkStage
		[cPathAdd,cPathDel]	= StageFileChange(strDirCombined,kStageAll(kS));
		
		cPathCum		= [cPathCum; cPathAdd];
		cPathExclude	= [cPathExclude; cPathDel];
		cPathCum		= setdiff(cPathCum,cPathDel);
	end
	
	cPathExclude	= setdiff(cPathExclude,cPathCum);

%------------------------------------------------------------------------------%
function [cPathAdd,cPathDel] = StageFileChange(strDirCombined,kStage)
% get the files added or deleted by the specified stage
	cFileAdd	= {};
	cFileDel	= {};
	
	switch kStage
		case 0
		case 1
			cFileAdd	= {'data.nii.gz';'sourcepath.txt'};
		case 2
			cFileAdd	= {'bvecs';'bvals'};
		case 3
			cFileAdd	= {'data-corrected.nii.gz';'data-corrected.ecclog'};
		case 4
			cFileAdd	= {'bvecs-orig'};
		case 5
			cFileDel	= {'data-corrected.nii.gz'};
		case 6
			cFileAdd	= {'nodif.nii.gz'};
		case 7
			cFileAdd	= {'nodif_brain_mask.nii.gz'};
		case 8
			cDTPrefix	= {'FA';'L1';'L2';'L3';'MD';'MO';'S0';'V1';'V2';'V3'};
			cFileAdd	= cellfun(@(x) ['dti_' x '.nii.gz'],cDTPrefix,'UniformOutput',false);
		case 9
			cDirCombined	= DirSplit(AddSlash(strDirCombined));
			strDirBedpostx	= DirAppend('..',[cDirCombined{end} '.bedpostX']);
			
			for kF=1:opt.nfibres
				strF	= num2str(kF);
				
				cFileAdd	= [cFileAdd; 	{['dyads' strF '_dispersion.nii.gz']
											['dyads' strF '.nii.gz']
											['mean_th' strF 'samples.nii.gz']
											['mean_ph' strF 'samples.nii.gz']
											['mean_f' strF 'samples.nii.gz']
											['merged_th' strF 'samples.nii.gz']
											['merged_ph' strF 'samples.nii.gz']
											['merged_f' strF 'samples.nii.gz']
											}];
			end
			cFileAdd	= [cFileAdd;	{''
										'bvecs'
										'bvals'
										'commands.txt'
										'logs'
										'mean_dsamples.nii.gz'
										'monitor'
										'nodif_brain_mask.nii.gz'
										'nodif_brain.nii.gz'
										'xfms'
										}];
			
			cFileAdd	= cellfun(@(x) PathUnsplit(strDirBedpostx,x),cFileAdd,'UniformOutput',false);
		otherwise
			error(['"' tostring(kStage) '" is not a valid stage.']);
	end
	
	cPathAdd	= cellfun(@(x) PathRel2Abs(x,strDirCombined),cFileAdd,'UniformOutput',false);
	cPathDel	= cellfun(@(x) PathRel2Abs(x,strDirCombined),cFileDel,'UniformOutput',false);
end
%------------------------------------------------------------------------------%

end
