function kStage = DTICombineGetStage(cDirCombined,varargin)
% DTICombineGetStage
% 
% Description:	get the current DTICombine stage of a set of combined DTI
%				directories
% 
% Syntax:	kStage = DTICombineGetStage(cDirCombined,<options>)
% 
% In:
%	cDirCombined	- the combined DTI directory, or a cell of combined
%					  directories
%	<options>:
%		nfibres:	(2) the number of fibers specified in the bedpostx advanced
%					options
%		offset:		(0) specify an integer if the return stage should be offset
%					from the actual stage (e.g. to check for the next stage to
%					process)
%		silent:		(false) true to suppress status output
% 
% Out:
% 	kStage		- the current DTICombine processing stage of the specified
%				  combined session
%					stage	0:	nothing exists that should
%							1:	concatenated data exists
%							2:	the concatenated bvecs and bvals were saved
%							3:	the data have been eddy corrected
%							4:	the bvecs have been rotated
%							5:	the data have been averaged, if specified
%							6:	the b0 image is saved
%							7:	the b0 brain is extracted
%							8:	dtifit has been run
%							9:	bedpostx has been run
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt			= ParseArgs(varargin,...
				'nfibres'	, 2		, ...
				'offset'	, 0		, ...
				'silent'	, false	  ...
				);
kStageAll	= 0:9;
nStage		= numel(kStageAll);

cDirCombined	= ForceCell(cDirCombined);
sCombined		= size(cDirCombined);
nCombined		= numel(cDirCombined);
kStage			= zeros(sCombined);

progress('action','init','total',nCombined,'label','Determining DTI Processing Stage','silent',opt.silent)
for kC=1:nCombined
	for kS=nStage:-1:1
		[cPathCum,cPathExclude] = DTICombineStageFiles(cDirCombined{kC},kStageAll(kS),'nfibres',opt.nfibres);
		
		if all(FileExists(cPathCum)) && ~any(FileExists(cPathExclude))
			break;
		end
	end
	
	kS	= max(1,kS+opt.offset);
	if kS>nStage
		kStage(kC)	= kStageAll(nStage)+opt.offset;
	else
		kStage(kC)	= kStageAll(kS);
	end
	
	progress;
end
