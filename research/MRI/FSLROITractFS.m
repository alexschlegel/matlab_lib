function [bSuccess,cPathROI,cName1,cName2,cPathROISingle,cNameSingle] = FSLROITractFS(cDirFSSubject,cDirFSLSubject,cLabel,varargin)
% FSLROITractFS
% 
% Description:	create a set of ROIs defining tracts between FreeSurfer
%				aparc.a2009s+aseg labels.  ROIs are created in FA-space.
% 
% Syntax:	[bSuccess,cPathROI,cName1,cName2,cPathROISingle,cNameSingle] = FSLROITractFS(cDirFSSubject,cDirFSLSubject,cLabel,<options>) OR
%			cScript = FSLROITractFS(cDirFSSubject,cDirFSLSubject,cLabel,cHemisphere,'dotract',false,<options>)
% 
% In:
% 	cDirFSSubject	- a path/cell of paths to FreeSurfer subject directories
%	cDirFSLSubject	- a path/cell of paths to FSL directories containing DTI
%					  data for the corresponding FreeSurfer subjects, processed
%					  through the bedpostX stage
%	cLabel			- a cell of aparc a2009s or aseg label names (or cells of
%					  label names to merge labels) (see the aseg and a2009s
%					  labels in FreeSurferLabels.  Note: use the surface labels
%					  [a2009s], not the volume labels [a2009svol]).  a tract ROI
%					  will be created between every pair of labels.  NOTE:
%					  only structures with left and right hemisphere components
%					  are supported, since it would be a pain to incorporate
%					  others and i don't anticipate using them.
%	<options>:
%		name:				(<auto>) a cell of the names to use for each label
%							('lh.' and 'rh.' are added)
%		hemisphere:			('both') 'lh', 'rh', or 'both' to specify
%							hemisphere(s) for which to save tracts
%		crop:				(<no crop>) a cell (or cell of cells) of the
%							fractional bounding boxes to crop from each label
%							(see FreeSurferMask)
%		bilateral:			(true) true to also create tracts for
%							interhemispheric connections
%		pair:				(true) true to run probtrackX for label pairs
%		single:				(false) true to run probtrackX for each label
%							individually
%		roicutoff:			(<FSLPaths2ROI default>) the cutoff value for the
%							conversion of the probtrackx result to an ROI.  see
%							FSLPaths2ROI.
%		roicutoffmethod:	(<FSLPaths2ROI default>) the method for calculating
%							the cutoff for converting probtrackx results to ROIs
%		roimethod:			(<FSLPaths2ROI default>) the method to use to convert
%							the probtrackx result to an ROI.  see FSLPaths2ROI.
%		wmstopmask:			(<FSLProbtrackx default>) true to use the inverse of
%							the FreeSurfer white matter mask as a termination
%							mask.  Matt Glasser recommends this in the FSL
%							mailing list.
%		wm_grow:			(<FSLProbtrackx default>) the number of pixels by
%							which to grow the inverse stop mask.  e.g. with a
%							value of -1, the mask will include one layer of gray
%							matter pixels past the white matter boundary.
%		nsample:			(<FSLProbtrackx default>) the number of samples to
%							send out from each voxel in each label
%		nstep:				(<FSLProbtrackx default>) the number of steps per
%							sample
%		steplength:			(<FSLProbtrackx default>) the length of each sample
%							step, in mm
%		threshcurvature:	(<FSLProbtrackx default>) the curvature threshold for
%							choosing each samples next position at each step
%		lengthcorrect:		(<FSLProbtrackx default>) set to true to multiply
%							each voxel's output value by the expected length of
%							tracts that cross it. somewhere on the FSL mailing
%							list it is mentioned that this isn't recommended for
%							quantitative studies, only for classification.
%		usef:				(<FSLProbtrackx default>) use anisotropy to constrain
%							tracking
%		modeuler:			(<FSLProbtrackx default>) true to use modified euler
%							streaming.  this is apparently more accurate but
%							takes longer.
%		rseed:				(<FSLProbtrackx default>) the random seed value for
%							tracking
%		force:				(true) true to force calculation of ROIs even if
%							the output files already exist
%		forcetract:			(false) true to force running of probtrackx even if
%							the paths already exist
%		forceprep:			(false) true to force preprocessing (e.g.
%							calculation of transforms, etc.)
%		dotract:			(true) true to actually calculate perform the
%							tractography.  if false, then all the
%							pre-tractography steps will be performed, no ROIs
%							will be calculated, and the first return argument
%							will be a cell of commands to probtrackx (e.g. for
%							performing the tractography on a cluster instead of
%							in this function)
%		cores:				(1) the number of processor cores to use
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	bSuccess		- true if the tracts were successfully created
%	cPathROI		- a cell/cell of cells of paths to the pairwise tract ROIs.
%					  File paths are formatted as:
%						<strDirFSLSubject>.probtrackX/<hemi1>.<label1>-to-<hemi2>.<label2>/roi.nii.gz
%	cName1			- a cell/cell of cells of names of the first label in each
%					  tract
%	cName2			- a cell/cell of cells of names of the second label in each
%					  tract
%	cPathROISingle	- a cell/cell of cells of paths to the single tract ROIs.
%					  File paths are formatted as:
%						<strDirFSLSubject>.probtrackX/<hemi1>.<label1>/roi.nii.gz
%	cNameSingle		- a cell/cell of cells of names of the single tract labels
%	cScript			- a cell of scripts for each call to probtrackx
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bSuccess												= false;
[cPathROI,cName1,cName2,cPathROISingle,cNameSingle]	= deal([]);

opt	= ParseArgs(varargin,...
		'name'				, []		, ...
		'hemisphere'		, 'both'	, ...
		'crop'				, []		, ...
		'bilateral'			, true		, ...
		'pair'				, true		, ...
		'single'			, false		, ...
		'roicutoff'			, []		, ...
		'roicutoffmethod'	, []		, ...
		'roimethod'			, []		, ...
		'wmstopmask'		, []		, ...
		'wm_grow'			, []		, ...
		'nsample'			, []		, ...
		'nstep'				, []		, ...
		'steplength'		, []		, ...
		'threshcurvature'	, []		, ...
		'lengthcorrect'		, []		, ...
		'usef'				, []		, ...
		'modeuler'			, []		, ...
		'rseed'				, []		, ...
		'force'				, true		, ...
		'forcetract'		, false		, ...
		'forceprep'			, false		, ...
		'dotract'			, true		, ...
		'cores'				, 1			, ...
		'silent'			, false		  ...
		);

cHemi	= reshape(ForceCell(conditional(isequal(lower(opt.hemisphere),'both'),{'lh','rh'},opt.hemisphere)),[],1);
nHemi	= numel(cHemi);

[cDirFSSubject,cDirFSLSubject,bUnCell,b]	= ForceCell(cDirFSSubject,cDirFSLSubject);
[cDirFSSubject,cDirFSLSubject]				= varfun(@(c) reshape(c,[],1),cDirFSSubject,cDirFSLSubject);
cSubject									= cellfun(@(d) cell2mat(DirSplit(d,'limit',1)),cDirFSSubject,'UniformOutput',false);
nSubject									= numel(cDirFSSubject);

[cLabel,cName,cCrop]	= varfun(@(x) ForceCell(reshape(x,[],1)),cLabel,opt.name,opt.crop);
[cLabel,cName,cCrop]	= FillSingletonArrays(cLabel,cName,cCrop);
nLabel					= numel(cLabel);

%calculate freesurfer <--> fa registration for each subject
	[bSuccess,cPathXFM]	= FreeSurfer2FA(cDirFSSubject,cDirFSLSubject,...
							'force'		, opt.forceprep		, ...
							'cores'		, opt.cores			, ...
							'silent'	, opt.silent		  ...
							);
	
	if ~all(bSuccess)
		status(['Could not calculate the FreeSurfer<-->FA registration for the following subjects: ' 10 join(cSubject(~bSuccess),10)],'warning',true,'silent',opt.silent); 
		return;
	end
%create the masks for each subject
	cPathRef					= cellfun(@(d) PathUnsplit(d,'nodif_brain_mask','nii.gz'),cDirFSLSubject,'UniformOutput',false);
	[cPathSingle,cNameSingle]	= deal(repmat({repmat({cell(nLabel,1)},[nHemi 1])},[nSubject 1]));
	
	cDirMask	= cellfun(@(d) DirAppend(d,'mask'),cDirFSLSubject,'UniformOutput',false);
	bSuccess	= cellfun(@CreateDirPath,cDirMask);
	
	if ~all(bSuccess)
		status(['Could not create the following mask directories: ' 10 join(cDirMask(~b),10)],'warning',true,'silent',opt.silent);
		return;
	end
	
	%replicate cells
		cS		= repmat(reshape(cSubject,[],1,1)		, [1 nHemi nLabel]);
		cDFS	= repmat(reshape(cDirFSSubject,[],1,1)	, [1 nHemi nLabel]);
		cL		= repmat(reshape(cLabel,1,1,[])			, [nSubject nHemi 1]);
		cH		= repmat(reshape(cHemi,1,[],1)			, [nSubject 1 nLabel]);
		cN		= repmat(reshape(cName,1,1,[])			, [nSubject nHemi 1]);
		cC		= repmat(reshape(cCrop,1,1,[])			, [nSubject nHemi 1]);
		cPXFM	= repmat(reshape(cPathXFM,[],1,1)		, [1 nHemi nLabel]);
		cPRef	= repmat(reshape(cPathRef,[],1,1)		, [1 nHemi nLabel]);
		cDMask	= repmat(reshape(cDirMask,[],1,1)		, [1 nHemi nLabel]);
	%create the masks
		[bSuccess,cPathSingle,cNameSingle]	= MultiTask(@FreeSurferMask,{cDFS cL cH,...
											'name'			, cN			, ...
											'crop'			, cC			, ...
											'xfm'			, cPXFM			, ...
											'ref'			, cPRef			, ...
											'xfm_suffix'	, 'diffusion'	, ...
											'outdir'		, cDMask		, ...
											'force'			, opt.forceprep	, ...
											'forceprep'		, opt.forceprep	, ...
											'silent'		, opt.silent	  ...
											},...
											'description'	, 'Extracting and merging masks'	, ...
											'cores'			, opt.cores							, ...
											'silent'		, opt.silent						  ...
											);
		bSuccess	= cellfun(@notfalse,bSuccess);
		
		if ~all(bSuccess)
			cSL	= cellfun(@(s,L) [s '/' L],cS(~bSuccess),cL(~bSuccess),'UniformOutput',false);
			
			status(['Could not extract the following subject labels:' 10 join(cSL,10)],'warning',true,'silent',opt.silent);
			return;
		end
		
	%reformat the mask paths
		%first by subject
			[cPathSingle,cNameSingle]	= varfun(@(c) mat2cell(c,ones(nSubject,1),nHemi,nLabel),cPathSingle,cNameSingle);
		%now by hemisphere
			[cPathSingle,cNameSingle]	= varfun(@(c) cellfun(@(x) mat2cell(squeeze(x),ones(nHemi,1),nLabel),c,'UniformOutput',false),cPathSingle,cNameSingle);
		%reshape by label
			[cPathSingle,cNameSingle]	= varfun(@(c) cellfun(@(x) cellfun(@(y) reshape(y,[],1),x,'UniformOutput',false),c,'UniformOutput',false),cPathSingle,cNameSingle);
%get the pairings to connect
	if opt.bilateral
		%combine hemispheres for each subject
			cPathSingle	= cellfun(@(s) append(s{:}),cPathSingle,'UniformOutput',false);
			cNameSingle	= cellfun(@(s) append(s{:}),cNameSingle,'UniformOutput',false);
		%get the pairings for each subject
			[cPath,kPath]	= cellfun(@(s) handshakes(s),cPathSingle,'UniformOutput',false);
			cPath1			= cellfun(@(c) c(:,1),cPath,'UniformOutput',false);
			cPath2			= cellfun(@(c) c(:,2),cPath,'UniformOutput',false);
			cName1			= cellfun(@(n,k) n(k(:,1)),cNameSingle,kPath,'UniformOutput',false);
			cName2			= cellfun(@(n,k) n(k(:,2)),cNameSingle,kPath,'UniformOutput',false);
	else
		%get the pairings for each hemisphere
			[cPath,kPath]	= cellfun(@(s) cellfun(@(h) handshakes(h),s,'UniformOutput',false),cPathSingle,'UniformOutput',false);
			cName1			= cellfun(@(n,k) cellfun(@(nh,kh) nh(kh(:,1)),n,k,'UniformOutput',false),cPathSingle,kPath,'UniformOutput',false);
			cName2			= cellfun(@(n,k) cellfun(@(nh,kh) nh(kh(:,2)),n,k,'UniformOutput',false),cPathSingle,kPath,'UniformOutput',false);
		%combine hemispheres
			cPath1							= cellfun(@(c) cellfun(@(c2) c2(:,1),c,'UniformOutput',false),cPath,'UniformOutput',false);
			cPath2							= cellfun(@(c) cellfun(@(c2) c2(:,2),c,'UniformOutput',false),cPath,'UniformOutput',false);
			[cPath1,cPath2,cName1,cName2]	= varfun(@(c) cellfun(@(s) append(s{:}),c,'UniformOutput',false),cPath1,cPath2,cName1,cName2);
	end
	
	%break out!
		nPairPer	= numel(cPath1{1});
		nSinglePer	= numel(cPathSingle{1});
		
		[cPath1All,cPath2All,cName1All,cName2All,cPathSingleAll,cNameSingleAll]	= varfun(@(c) append(c{:}),cPath1,cPath2,cName1,cName2,cPathSingle,cNameSingle);
	%replicate other variables
		[cSubjectAll,cDirFSSubjectAll,cDirFSLSubjectAll]						= varfun(@(d) reshape(repmat(reshape(d,1,[]),[nPairPer 1]),[],1),cSubject,cDirFSSubject,cDirFSLSubject);
		[cSubjectSingleAll,cDirFSSubjectSingleAll,cDirFSLSubjectSingleAll]	= varfun(@(d) reshape(repmat(reshape(d,1,[]),[nSinglePer 1]),[],1),cSubject,cDirFSSubject,cDirFSLSubject);
	
	nTract	= numel(cSubjectAll);
	nSingle	= numel(cSubjectSingleAll);
%run probtrackx once for each subject to prepare files
	cOpt				= [opt2cell(structsub(opt,{'wmstopmask','wm_grow','nsample','nstep','steplength','threshcurvature','lengthcorrect','usef','modeuler','rseed','silent'})) 'seedspace' 'diffusion' 'force' opt.forceprep];
	[bSuccess,cNameDel]	= cellfunprogress(@(dfs,dfsl) FSLProbtrackx(dfsl,{},'dir_fs',dfs,cOpt{:}),cDirFSSubject,cDirFSLSubject,'UniformOutput',false,'label','Preparing probtrackx for each subject');
	bSuccess			= cellfun(@notfalse,bSuccess);
	
	if ~all(bSuccess)
		status(['Could not prepare probtrackx for the following subjects: ' 10 join(cSubject(~bSuccess),',')],'warning',true,'silent',opt.silent);
		return;
	end
	
	%delete the temporary directories
		cellfun(@(d,n) rmdir(FSLDirTract(d,n),'s'),cDirFSLSubject,cNameDel);

cScript	= {};

if opt.pair
%calculate the ROI for each pair
	%get the tracts that need to be calculated
		if ~opt.force && opt.dotract
			%get the suffix
				strSuffix	= '';
				
				if opt.lengthcorrect
					strSuffix	= [strSuffix '_lc'];
				end
			
			cDirPTX		= cellfun(@(d) AddSlash([RemoveSlash(d) '.probtrackX'],false),cDirFSLSubjectAll,'UniformOutput',false);
			cNameTract	= cellfun(@(n1,n2) [n1 '-to-' n2],cName1All,cName2All,'UniformOutput',false);
			cDirTract	= cellfun(@DirAppend,cDirPTX,cNameTract,'UniformOutput',false);
			cPathROI	= cellfun(@(d) PathUnsplit(d,['roi' strSuffix],'nii.gz'),cDirTract,'UniformOutput',false);
			
			bDo	= ~cellfun(@FileExists,cPathROI);
		else
			[cPathROI,cNameTract]	= deal(cell(nTract,1));
			bDo						= true(nTract,1);
		end
	
	cOptPTX			= opt2cell(structsub(opt,{'wmstopmask','wm_grow','nsample','nstep','steplength','threshcurvature','lengthcorrect','usef','modeuler','rseed','silent'}));
	nCore			= conditional(opt.dotract,opt.cores,1);
	
	bSuccessPair	= true(nTract,1);
	if any(bDo)
		[b,cPathROI(bDo),cNameTract(bDo)]	= MultiTask(@ROITract,{cDirFSSubjectAll(bDo),cDirFSLSubjectAll(bDo),cPath1All(bDo),cPath2All(bDo),cName1All(bDo),cName2All(bDo)},...
												'description'	, 'Calculating pairwise tracts'	, ...
												'cores'			, nCore							, ...
												'silent'		, opt.silent					  ...
												);
	else
		b	= {};
	end
	
	if ~opt.dotract
	%return the scripts
		cScript	= [cScript; b];
	else
	%separate results by subject
		if ~bUnCell
			[cPathROI,cName1,cName2]	= varfun(@(c) mat2cell(reshape(c,nPairPer,nSubject),nPairPer,ones(1,nSubject)),cPathROI,cName1All,cName2All);
		end
	%make sure the tracts were created
		bSuccessPair(bDo)	= cellfun(@notfalse,b);
		
		if ~all(bSuccessPair)
			cST	= cellfun(@(s,t) [s '/' t],cSubjectAll(~bSuccessPair),cNameTract(~bSuccessPair),'UniformOutput',false);
			
			status(['The following tract ROIs were not successfully created: ' 10 join(cST,10)],'warning',true,'silent',opt.silent);
			return;
		end
	end
end

if opt.single
%calculate the ROI for each pair
	%get the tracts that need to be calculated
		if ~opt.force && opt.dotract
			%get the suffix
				strSuffix	= '';
				
				if opt.lengthcorrect
					strSuffix	= [strSuffix '_lc'];
				end
			
			cDirPTX				= cellfun(@(d) AddSlash([RemoveSlash(d) '.probtrackX'],false),cDirFSLSubjectSingleAll,'UniformOutput',false);
			cNameTractSingle	= cNameSingleAll;
			cDirTract			= cellfun(@DirAppend,cDirPTX,cNameTractSingle,'UniformOutput',false);
			cPathROISingle		= cellfun(@(d) PathUnsplit(d,['roi' strSuffix],'nii.gz'),cDirTract,'UniformOutput',false);
			
			bDo	= ~cellfun(@FileExists,cPathROISingle);
		else
			[cPathROISingle,cNameTractSingle]	= deal(cell(nSingle,1));
			bDo									= true(nSingle,1);
		end
	
	cOptPTX			= opt2cell(structsub(opt,{'wmstopmask','wm_grow','nsample','nstep','steplength','threshcurvature','lengthcorrect','usef','modeuler','rseed','silent'}));
	nCore			= conditional(opt.dotract,opt.cores,1);
	
	bSuccessSingle	= true(nSingle,1);
	if any(bDo)
		[b,cPathROISingle(bDo),cNameTractSingle(bDo)]	= MultiTask(@ROITractSingle,{cDirFSSubjectSingleAll(bDo),cDirFSLSubjectSingleAll(bDo),cPathSingleAll(bDo),cNameSingleAll(bDo)},...
															'description'	, 'Calculating single-seed tracts'	, ...
															'cores'			, nCore								, ...
															'silent'		, opt.silent						  ...
															);
	else
		b	= {};
	end
	
	if ~opt.dotract
	%return the scripts
		cScript	= [cScript; b];
	else
	%separate results by subject
		if ~bUnCell
			[cPathROISingle,cNameSingle]	= varfun(@(c) mat2cell(reshape(c,nSinglePer,nSubject),nSinglePer,ones(1,nSubject)),cPathROISingle,cNameSingleAll);
		end
	%make sure the tracts were created
		bSuccessSingle(bDo)	= cellfun(@notfalse,b);
		
		if ~all(bSuccessSingle)
			cST	= cellfun(@(s,t) [s '/' t],cSubjectSingleAll(~bSuccessSingle),cNameTractSingle(~bSuccessSingle),'UniformOutput',false);
			
			status(['The following single-seed tract ROIs were not successfully created: ' 10 join(cST,10)],'warning',true,'silent',opt.silent);
			return;
		end
	end
end

%success!
	if opt.dotract
		bSuccess	= true;
	else
		bSuccess	= cScript;
	end

%------------------------------------------------------------------------------%
function [bSuccess,strPathROI,strName] = ROITract(strDirFS,strDirFSL,strPath1,strPath2,strName1,strName2)
	strName		= [strName1 '-to-' strName2];
	
	[bSuccess,strName]	= FSLProbtrackx(strDirFSL,{strPath1,strPath2},cOptPTX{:},...
							'seedspace'	, 'diffusion'		, ...
							'dir_fs'	, strDirFS			, ...
							'force'		, opt.forcetract	, ...
							'name'		, strName			, ...
							'dotract'	, opt.dotract		  ...
							);
	if opt.dotract && bSuccess
		[bSuccess,strPathROI]	= FSLTract2ROI(strDirFSL,strName,...
									'lengthcorrect'	, opt.lengthcorrect		, ...
									'cutoff'		, opt.roicutoff			, ...
									'cutoff_method'	, opt.roicutoffmethod	, ...
									'method'		, opt.roimethod			, ...
									'force'			, opt.force				, ...
									'silent'		, opt.silent			  ...
									);
	else
		strPathROI	= [];
	end
end
%------------------------------------------------------------------------------%
function [bSuccess,strPathROI,strName] = ROITractSingle(strDirFS,strDirFSL,strPath,strName)
	[bSuccess,strName]	= FSLProbtrackx(strDirFSL,strPath,cOptPTX{:},...
							'seedspace'	, 'diffusion'		, ...
							'dir_fs'	, strDirFS			, ...
							'force'		, opt.forcetract	, ...
							'name'		, strName			, ...
							'dotract'	, opt.dotract		  ...
							);
	if opt.dotract && bSuccess
		[bSuccess,strPathROI]	= FSLTract2ROI(strDirFSL,strName,...
									'lengthcorrect'	, opt.lengthcorrect		, ...
									'cutoff'		, opt.roicutoff			, ...
									'cutoff_method'	, opt.roicutoffmethod	, ...
									'method'		, opt.roimethod			, ...
									'force'			, opt.force				, ...
									'silent'		, opt.silent			  ...
									);
	else
		strPathROI	= [];
	end
end
%------------------------------------------------------------------------------%

end
