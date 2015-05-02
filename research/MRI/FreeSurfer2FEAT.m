function b = FreeSurfer2FEAT(cDirFreeSurfer,cDirFEAT,varargin)
% FreeSurfer2FEAT
% 
% Description:	construct transforms between freesurfer space and the spaces in
%				the FEAT reg folder
% 
% Syntax:	b = FreeSurfer2FEAT(cDirFreeSurfer,cDirFEAT,<options>)
% 
% In:
% 	cDirFreeSurfer	- the path to a freesurfer directory, or a cell of paths
%	cDirFEAT		- the path to a corresponding FEAT directory, or a cell of
%					  paths
%	<options>:
%		force:		(true) true to calculate transforms even if output files
%					already exist
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status output
% 
% Out:
% 	b	- a logical array indicating which sets of transforms were successfully
%		  created
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'force'		, true	, ...
		'cores'		, 1		, ...
		'silent'	, false	  ...
		);

[cDirFreeSurfer,cDirFEAT,bNoCell,dummy]	= ForceCell(cDirFreeSurfer,cDirFEAT);

b	= MultiTask(@TransformOne,{cDirFreeSurfer cDirFEAT},...
		'description'	, 'transforming freesurfer to feat spaces'	, ...
		'uniformoutput'	, true										, ...
		'cores'			, opt.cores									, ...
		'silent'		, opt.silent								  ...
		);

%------------------------------------------------------------------------------%
function b = TransformOne(strDirFreeSurfer,strDirFEAT)
	b	= false;
	
	strDirMRI			= DirAppend(strDirFreeSurfer,'mri');
	strPathFSBrain		= PathUnsplit(strDirMRI,'brain','nii.gz');
	strPathFSBrainMGZ	= PathUnsplit(strDirMRI,'brain','mgz');
%convert MGZ to NIfTI
	if ~FileExists(strPathFSBrain) && (~FileExists(strPathFSBrainMGZ) || ~MRIConvert(strPathFSBrainMGZ,strPathFSBrain,'silent',opt.silent))
		return;
	end
%transform from freesurfer to the FEAT space files
	cSpaceFEAT		= {'standard'; 'highres'; 'example_func'};
	strDirREG		= DirAppend(strDirFEAT,'reg');
	cPathFEAT		= cellfun(@(s) PathUnsplit(strDirREG,s,'nii.gz'),cSpaceFEAT,'UniformOutput',false);
	cPathFEATOut	= cellfun(@(s) PathUnsplit(strDirREG,['freesurfer2' s],'nii.gz'),cSpaceFEAT,'UniformOutput',false);
	
	if ~all(FileExists(cPathFEAT))
		return;
	end
	
	[b,cPathFEATOut,cPathFS2FEAT]	= FSLRegisterFLIRT(strPathFSBrain,cPathFEAT,...
										'output'		, cPathFEATOut	, ...
										'tkregfirst'	, true			, ...
										'force'			, opt.force		, ...
										'silent'		, opt.silent	  ...
										);
	
	if ~all(b)
		return;
	end
%compute the inverses
	cPathXFMInverse	= cellfun(@(s) PathUnsplit(strDirREG,[s '2freesurfer'],'mat'),cSpaceFEAT,'UniformOutput',false);
	
	if opt.force
		bProcess	= true(size(cPathXFMInverse));
	else
		bProcess	= ~FileExists(cPathXFMInverse);
	end
	
	cellfun(@(xfm,ixfm) FSLInvertTransform(xfm,'output',ixfm,'silent',opt.silent),cPathFS2FEAT(bProcess),cPathXFMInverse(bProcess),'UniformOutput',false);
%success!
	b	= true;
end
%------------------------------------------------------------------------------%

end
