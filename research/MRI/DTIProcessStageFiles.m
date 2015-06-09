function [cPathCum,cPathAdd,cPathDel] = DTIProcessStageFiles(strDirSession,kStage,varargin)
% DTIProcessStageFiles
% 
% Description:	return the files involved with each stage of DTIProcess (see
%				DTIProcessGetStage)
% 
% Syntax:	[cPathCum,cPathAdd,cPathDel] = DTIProcessStageFiles(strDirSession,kStage,<options>)
% 
% In:
% 	strDirSession	- the session directory
%	kStage			- the stage of interest
%	<options>:
%		nfibres:	(2) the number of fibers specified in the bedpostx advanced
%					options
% 
% Out:
% 	cPathCum	- a cell of paths to files that should exist after the specified
%				  stage is complete
%	cPathAdd	- a cell of paths to files that were added by the specified
%				  stage
%	cPathDel	- a cell of paths to files that were deleted by the specified
%				  stage
% 
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'nfibres'	, 2	  ...
		);

kStageAll	= [0 0.1 0.2 1:5];

strDirSession	= PathGetDir(AddSlash(strDirSession));

%get the cumulative file state of the specified stage
	kkStage	= find(kStage==kStageAll,1);
	
	[cPathCum,cPathAdd,cPathDel]	= deal({});
	
	for kS=1:kkStage
		[cPathAdd,cPathDel]	= StageFileChange(strDirSession,kStageAll(kS));
		
		cPathCum	= [cPathCum; cPathAdd];
		cPathCum	= setdiff(cPathCum,cPathDel);
	end

%------------------------------------------------------------------------------%
function [cPathAdd,cPathDel] = StageFileChange(strDirSession,kStage)
% get the files added or deleted by the specified stage
	cFileAdd	= {};
	cFileDel	= {};
	
	switch kStage
		case 0
		case 0.1
			cFileAdd	= {'data.(nii|nii\.gz)'};
		case 0.2
			cFileAdd	= {'bvecs';'bvals'};
		case 1
			cFileAdd	= {'nodif\.nii\.gz'};
		case 2
			cFileAdd	= {'nodif_brain_mask\.nii\.gz'};
		case 3
			cFileAdd	= {'data-orig\.(nii|nii\.gz)';'data\.ecclog';'bvecs-orig'};
		case 4
			cDTPrefix	= {'FA';'L1';'L2';'L3';'MD';'MO';'S0';'V1';'V2';'V3'};
			cFileAdd	= cellfun(@(x) ['dti_' x '\.nii\.gz'],cDTPrefix,'UniformOutput',false);
		case 5
			cDirSession	= DirSplit(AddSlash(strDirSession));
			strDirBedpostx	= DirAppend('..',[cDirSession{end} '.bedpostX']);
			
			for kF=1:opt.nfibres
				strF	= num2str(kF);
				
				cFileAdd	= [cFileAdd; 	{['dyads' strF '_dispersion\.nii\.gz']
											['dyads' strF '\.nii\.gz']
											['mean_th' strF 'samples\.nii\.gz']
											['mean_ph' strF 'samples\.nii\.gz']
											['mean_f' strF 'samples\.nii\.gz']
											['merged_th' strF 'samples\.nii\.gz']
											['merged_ph' strF 'samples\.nii\.gz']
											['merged_f' strF 'samples\.nii\.gz']
											}];
			end
			cFileAdd	= [cFileAdd;	{''
										'bvecs'
										'bvals'
										'commands\.txt'
										'logs/'
										'mean_dsamples\.nii\.gz'
										'monitor'
										'nodif_brain_mask\.nii\.gz'
										'nodif_brain\.nii\.gz'
										'xfms/'
										}];
			
			cFileAdd	= cellfun(@(x) PathUnsplit(strDirBedpostx,x),cFileAdd,'UniformOutput',false);
		otherwise
			error(['"' tostring(kStage) '" is not a valid stage.']);
	end
	
	cPathAdd		= cellfun(@(x) PathRel2Abs(x,strDirSession),cFileAdd,'UniformOutput',false);
	cPathDel		= cellfun(@(x) PathRel2Abs(x,strDirSession),cFileDel,'UniformOutput',false);

end
%------------------------------------------------------------------------------%

end
