function tl = FSLTractLength(cDirDTI,cNameTract,varargin)
% FSLTractLength
% 
% Description:	calculate the length of a tract created with FSLROITractFS.
%				FSLROITractFS must have been called twice:  once with
%				'lengthcorrect' true and once with it false.
% 
% Syntax:	tl = FSLTractLength(cDirDTI,cNameTract,<options>)
% 
% In:
% 	cDirDTI		- the DTI data directory path or cell of paths
%	cNameTract	- the name or cell of names of the tracts (i.e. the name of the
%				  tract folder in <strDirDTI>.probtrackX/) (one for each
%				  specified DTI directory).  tracts must be named
%				  <mask1>-to-<mask2> and have corresponding mask files named
%				  <strDirDTI>/mask/<mask>-diffusion.nii.gz.
%	<options>:
%		force:		(true) true to calculate the tract length even if a
%					previously saved tract length exists
%		forceprep:	(false) true to recalculate ROIs
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	tl	- an array of tract lengths, or NaN if the required files don't exist
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'force'		, true	, ...
		'forceprep'	, false	, ...
		'silent'	, false	  ...
		);

[cDirDTI,cNameTract]	= ForceCell(cDirDTI,cNameTract);
[cDirDTI,cNameTract]	= FillSingletonArrays(cDirDTI,cNameTract);

sTract	= size(cDirDTI);
nTract	= numel(cDirDTI);

tl	= NaN(sTract);

%get the output tract length files
	cDirTract	= cellfun(@FSLDirTract,cDirDTI,cNameTract,'UniformOutput',false);
	cPathTL		= cellfun(@(d) PathUnsplit(d,'tractlength','dat'),cDirTract,'UniformOutput',false);
%get the tract lengths to calculate
	if opt.force
		bCalc	= true(sTract);
	else
		bCalc	= ~FileExists(cPathTL);
	end
%read the previously stored tract lengths
	tl(~bCalc)	= cellfunprogress(@(f) fget(f,'precision','double'),cPathTL(~bCalc),'label','reading previously calculated tract lengths','silent',opt.silent);
%calculate the tract lengths
	if any(bCalc)
	%mask names
		cTractSplit	= cellfun(@(n) split(n,'-to-'),cNameTract(bCalc),'UniformOutput',false);
		bProper		= cellfun(@(s) numel(s)==2,cTractSplit);
		
% 		if ~all(bProper)
% 			bBad		= false(size(bCalc));
% 			bBad(bCalc)	= ~bProper;
			
% 			status(['The following tracts are not formatted correctly:' 10 join(cNameTract(bBad),10)],'warning',true,'silent',opt.silent);
% 		end
		
		[cNameMask1,cNameMask2]	= cellfun(@(s) deal(s{1},s{2}),cTractSplit(bProper),'UniformOutput',false);
		bCalc(bCalc)				= bProper;
	%required files
		cDirMask	= cellfun(@(d) DirAppend(d,'mask'),cDirDTI(bCalc),'UniformOutput',false);
		cPathMask1	= cellfun(@(d,n) PathUnsplit(d,[n '-diffusion'],'nii.gz'),cDirMask,cNameMask1,'UniformOutput',false);
		cPathMask2	= cellfun(@(d,n) PathUnsplit(d,[n '-diffusion'],'nii.gz'),cDirMask,cNameMask2,'UniformOutput',false);
		
		cPathTract		= cellfun(@FSLPathTract,cDirDTI(bCalc),cNameTract(bCalc),'UniformOutput',false);
		cPathTractLC	= cellfun(@(d,n) FSLPathTract(d,n,'lengthcorrect',true),cDirDTI(bCalc),cNameTract(bCalc),'UniformOutput',false);
		[b,cPathROI]	= cellfun(@(d,n) FSLTract2ROI(d,n,'force',opt.forceprep),cDirDTI(bCalc),cNameTract(bCalc),'UniformOutput',false);
		
		bReady			= true(sTract);
		bReady(bCalc)	= cell2mat(b) & cellfun(@(varargin) all(FileExists(varargin)),cPathMask1,cPathMask2,cPathTract,cPathTractLC);
		
		if any(~bReady(:))
			status(['The following tract directories are not ready: ' 10 join(cDirTract(~bReady),10)],'warning',true,'silent',opt.silent);
		end
	%calculate
		bDo					= bReady(bCalc);
		tl(bCalc & bReady)	= cellfunprogress(@CalcTractLength,cPathMask1(bDo),cPathMask2(bDo),cPathTract(bDo),cPathTractLC(bDo),cPathROI(bDo),cPathTL(bCalc & bReady),'label','calculating tract lengths');
	end

%------------------------------------------------------------------------------%
function tl = CalcTractLength(strPathMask1,strPathMask2,strPathTract,strPathTractLC,strPathROI,strPathTL)
	%load each
		[dM1,dM2,dT,dTLC,dROI]	= varfun(@(f) double(NIfTI.Read(f,'return','data')),strPathMask1,strPathMask2,strPathTract,strPathTractLC,strPathROI);
	%get the seed mask voxels included in the ROI
		bMR	= (dM1 | dM2) & dROI>0;
	%get the expected tract length at each voxel
		tl	= dTLC(bMR)./dT(bMR);
	%get the weighted expected tract length
		roiMR		= dROI(bMR);
		roiMRTotal	= sum(roiMR);
		
		if roiMRTotal>0
			tl	= sum(tl .* roiMR./roiMRTotal);
		else
			tl	= NaN;
		end
		
		if isnan(tl)
			x=1;
		end
	%save the output
		fput(tl,strPathTL);
end
%------------------------------------------------------------------------------%

end
