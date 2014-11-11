function [fConnect,fOverlap] = FSLTractConnectivity(cDirDTI,cNameTract,varargin)
% FSLTractConnectivity
% 
% Description:	calculate the connectivity of a set of tracts
% 
% Syntax:	[fConnect,fOverlap] = FSLTractConnectivity(cDirDTI,cNameTract,<options>)
% 
% In:
% 	cDirDTI		- the DTI data directory path or cell of paths
%	cNameTract	- the name or cell of names of the tracts (i.e. the name of the
%				  tract folder in <strDirDTI>.probtrackX/) (one for each
%				  specified DTI directory).  tracts must be named
%				  <mask1>-to-<mask2> and have corresponding mask files named
%				  <strDirDTI>/mask/<mask>-diffusion.nii.gz.
%	<options>:
%		nsample:		(5000) the --nsamples option passed to probtrackx
%		lengthcorrect:	(false) true to lengthcorrect fConnect
%		force:			(true) true to calculate the tract length even if a
%						previously saved tract length exists
%		forceprep:		(false) true to recalculate ROIs and required values
%		silent:			(false) true to suppress status messages
% 
% Out:
%	fConnect		- an array of connection factors, i.e. the fraction of
%					  samples sent out that made it between the masks, optionally
%					  multiplied by the tract length, or NaNs where the required
%					  files don't exist
%	fOverlap		- an array of overlap factors, i.e. the mean of the number of
%					  samples incident on each voxel in the tract ROI (minus 1)
%					  divided by the total number of connecting samples
%					  (minus 1), or NaNs where the required files don't exist
% 
% Updated: 2011-03-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'nsample'		, 5000	, ...
		'lengthcorrect'	, false	, ...
		'force'			, true	, ...
		'forceprep'		, false	, ...
		'silent'		, false	  ...
		);

[cDirDTI,cNameTract]	= ForceCell(cDirDTI,cNameTract);
[cDirDTI,cNameTract]	= FillSingletonArrays(cDirDTI,cNameTract);

sTract	= size(cDirDTI);
nTract	= numel(cDirDTI);

[fConnect,fOverlap]	= deal(NaN(sTract));

%get the output connectivity files
	cDirTract	= cellfun(@FSLDirTract,cDirDTI,cNameTract,'UniformOutput',false);
	cPathC		= cellfun(@(d) PathUnsplit(d,'connectivity','dat'),cDirTract,'UniformOutput',false);
%get the tract lengths to calculate
	if opt.force
		bCalc	= true(sTract);
	else
		bCalc	= ~FileExists(cPathC);
	end
%read the previously stored connectivities
	c	= cellfunprogress(@(f) fget(f,'precision','double'),cPathC(~bCalc),'UniformOutput',false,'label','reading previously calculated connectivities','silent',opt.silent);
	
	[fConnect(~bCalc),fOverlap(~bCalc)]	= cellfun(@(d) deal(d(1),d(2)),c);
%calculate the connectivities
	if any(bCalc)
		bForceROI	= opt.forceprep;
	
	%waytotals
		status('calculating waytotals','silent',opt.silent);
		nWaytotal	= FSLTractWaytotal(cDirDTI(bCalc),cNameTract(bCalc),'silent',opt.silent);
	%tract lengths
		if opt.lengthcorrect
			status('length correcting','silent',opt.silent);
			
			tl			= FSLTractLength(cDirDTI(bCalc),cNameTract(bCalc),'force',opt.forceprep,'forceprep',bForceROI,'silent',opt.silent);
			bForceROI	= false;
		else
			tl	= ones(size(nWaytotal));
		end
	%mean tract value
		status('calculating tract means','silent',opt.silent);
		m	= FSLTractMean(cDirDTI(bCalc),cNameTract(bCalc),'force',opt.forceprep,'forceprep',bForceROI,'silent',opt.silent);
	%calculate the total number of samples sent
		status('calculating tract sample totals','silent',opt.silent);
		nSent	= FSLTractSamplesSent(cDirDTI(bCalc),cNameTract(bCalc),opt.nsample,'force',opt.forceprep,'silent',opt.silent);
	%calculate
		bDo				= ~isnan(nWaytotal) & ~isnan(tl) & ~isnan(m) & ~isnan(nSent);
		bCalc(bCalc)	= bDo;
		
		fConnect(bCalc)			= tl(bDo).*(nWaytotal(bDo)./nSent(bDo));
		fOverlap(bCalc)			= (m(bDo) - 1)./(nWaytotal(bDo) - 1);
	%save the output
		if any(bCalc)
			cellfunprogress(@(f,fc,fo) fput([fc;fo],f),cPathC(bCalc),num2cell(fConnect(bCalc)),num2cell(fOverlap(bCalc)),'label','saving connectivity results');
		end
	end
	