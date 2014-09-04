function kStage = FLTBSSGetStage(strDirTBSS)
% FSLTBSSGetStage
% 
% Description:	get the current stage of a TBSS process
% 
% Syntax:	kStage = FLTBSSGetStage(strDirTBSS)
% 
% In:
% 	strDirTBSS	- the TBSS directory
% 
% Out:
% 	kStage	- the stage.  one of the following:
%				0:	nothing has been done
%				1:	preprocessing complete
%				2:	registration complete
%				3:	post-registration complete
%				4:	pre-stats complete
% 
% Updated: 2010-12-06
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strDirStats	= DirAppend(strDirTBSS,'stats');
strDirOrig	= DirAppend(strDirTBSS,'origdata');
strDirFA	= DirAppend(strDirTBSS,'FA');

%check for stage four
	strPathFASkeleton	= PathUnsplit(strDirStats,'all_FA_skeletonised','nii.gz');
	if FileExists(strPathFASkeleton)
		kStage	= 4;
		return;
	end
%check for the important stage three files
	strPathFAAll			= PathUnsplit(strDirStats,'all_FA','nii.gz');
	strPathFAMean			= PathUnsplit(strDirStats,'mean_FA','nii.gz');
	strPathFAMeanSkeleton	= PathUnsplit(strDirStats,'mean_FA_skeleton','nii.gz');
	if all(FileExists({strPathFAAll strPathFAMean strPathFAMeanSkeleton}))
		kStage	= 3;
		return;
	end
%stage zero, one, or two?
	if isdir(strDirTBSS)
	%TBSS has started
		cPathFAOrig	= FindFilesByExtension(strDirTBSS,'nii.gz');
		nFAOrig		= numel(cPathFAOrig);
		
		if nFAOrig==0
		%original files are moved or missing
			kStage	= 0;
		else
		%original files exist
			cPathFAToTarget	= cellfun(@(x) PathUnsplit(strDirFA,[PathGetFilePre(x) '_FA_to_target_warp'],'nii.gz'),cPathFAOrigMoved,'UniformOutput',false);
			
			if all(FileExists(cPathFAToTarget))
			%stage 2 files have been created
				kStage	= 2;
			else
			%stage 2 files have not been created
				cPathFAOrigMoved	= FindFilesByExtension(strDirOrig,'nii.gz');
				nFAOrigMoved		= numel(cPathFAOrigMoved);
				
				if nFAOrigMoved==0
				%original files are missing
					kStage	= 0;
				else
				%original files have been moved
					kStage	= 1;
				end
			end
		end
	else
	%TBSS hasn't started
		kStage	 = 0;
	end
	