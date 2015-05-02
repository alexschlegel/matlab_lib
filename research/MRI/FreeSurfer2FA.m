function [bSuccess,cPathXFM,cPathXFMInv] = FreeSurfer2FA(cDirFS,cDirFA,varargin)
% FreeSurfer2FA
% 
% Description:	calculate transforms from a FreeSurfer sructural volume to a
%				corresponding FSL FA volume
% 
% Syntax:	[bSuccess,cPathXFM,cPathXFMInv] = FreeSurfer2FA(cDirFS,cDirFA,<option>)
% 
% In:
%	cDirFS	- the path or cell of paths to the subjects' FreeSurfer directories
% 	cDirFA	- the path or cell of paths to the subjects' FA directories
%			  (i.e. containing a dti_FA.nii.gz volume)
%	<options>:
%		method:		('flirt') flirt or fnirt
%		force:		(true) true to calculate transforms even if output files
%					already exist
%		log:		(true) true to save logs
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status output
% 
% Out:
%	bSuccess	- a logical array indicating which calculations were successful 
% 	cPathXFM	- path/cell of paths to the FreeSurfer-->FA transform matrices
%				  or warp files
%	cPathXFMInv	- path/cell of paths to the FA-->FreeSurfer transform matrices
%				  or warp files
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bSuccess				= false;
[cPathXFM,cPathXFMInv]	= deal([]);

opt	= ParseArgs(varargin,...
		'method'	, 'flirt'	, ...
		'force'		, true		, ...
		'log'		, true		, ...
		'cores'		, 1			, ...
		'silent'	, false		  ...
		);

if ~ismember(lower(opt.method),{'flirt','fnirt'})
	error(['"' tostring(opt.method) '" is not a valid FreeSurfer-->FA method.']);
end

%calculate multiple transforms
	if iscell(cDirFS)
		cOpt	= opt2cell(rmfield(opt,'cores'));
		
		[bSuccess,cPathXFM,cPathXFMInv]	= MultiTask(@FreeSurfer2FA,{cDirFS cDirFA cOpt{:}},...
												'description'	, 'Calculating FreeSurfer<-->FA transforms'	, ...
												'cores'			, opt.cores									, ...
												'silent'		, opt.silent								  ...
												);
		bSuccess							= cell2mat(bSuccess);
		
		return;
	end

strDirMRI		= DirAppend(cDirFS,'mri');
strSubjectFS	= cell2mat(DirSplit(AddSlash(cDirFS),'limit',1));

%convert the FreeSurfer brain to NIfTI
	strPathBrainMGZ	= PathUnsplit(strDirMRI,'brain','mgz');
	strPathBrainNII	= PathAddSuffix(strPathBrainMGZ,'','nii.gz');
	
	if ~MRIConvert(strPathBrainMGZ,strPathBrainNII,'log',opt.log,'force',opt.force,'silent',opt.silent)
		return;
	end
%transform FSL to FreeSurfer
	strFS	= ['freesurfer_' strSubjectFS];
	strFA	= 'fa';
	
	strXFM		= [strFS '2' strFA];
	strXFMInv	= [strFA '2' strFS];
	
	strPathFAIn		= PathUnsplit(cDirFA,'dti_FA','nii.gz');
	strPathFAOut	= PathUnsplit(cDirFA,strXFMInv,'nii.gz');
	
	switch lower(opt.method)
		case 'flirt'
			[cPathXFM,cPathXFMInv]	= varfun(@(s) PathUnsplit(cDirFA,s,'mat'),strXFM,strXFMInv);
			
			
			%flirt FA to FreeSurfer
				if ~FSLRegisterFLIRT(strPathFAIn,strPathBrainNII,...
										'output'		, strPathFAOut	, ...
										'tkregfirst'	, true			, ...
										'force'			, opt.force		, ...
										'log'			, opt.log		, ...
										'silent'		, opt.silent	  ...
										)
					return;
				end
			%calculate the inverse
				if isempty(FSLInvertTransform(cPathXFMInv,'output',cPathXFM,'silent',opt.silent))
					return;
				end
		case 'fnirt'
			[cPathXFM,cPathXFMInv]	= varfun(@(s) PathUnsplit(cDirFA,[s '-warp'],'nii.gz'),strXFM,strXFMInv);
			
			%fnirt FA to FreeSurfer
				if ~FSLRegisterFNIRT(strPathFAIn,strPathBrainNII,...
										'output'		, strPathFAOut	, ...
										'betfirst'		, false			, ...
										'tkregfirst'	, true			, ...
										'flirtfirst'	, true			, ...
										'force'			, opt.force		, ...
										'log'			, opt.log		, ...
										'silent'		, opt.silent	  ...
										)
					return;
				end
			%calculate the inverse
				if isempty(FSLInvertWarp(cPathXFMInv,strPathFAIn,'output',cPathXFM,'silent',opt.silent))
					return;
				end
	end
%success!
	bSuccess	= true;
