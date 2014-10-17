function strPathPCorr = StatFDRCorrect(strPathP,varargin)
% StatFDRCorrect
% 
% Description:	false discovery rate correct a volume of p values
% 
% Syntax:	strPathPCorr = StatFDRCorrect(strPathP,<options>)
% 
% In:
% 	strPathP	- the path to a NIfTI volume of p values, or an FSL directory
%				  containing p volumes from randomise
%	<options>:
%		dependent:	(false) true if independence or positive correlation should
% 					not be assumed among the p values
%		invert:		(<true if fsl-type file, false otherwise>) true if p-values
%					are stored as 1-p
%		mask:		(<none>) the path to a mask to use, or the file name of a
%					mask that exists in the same directory as the input file
%		output:		(<auto>) the path to the output file(s)
%		force:		(true) true to force recalculation of pre-existing
%					FDR-corrected files
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	strPathCorr	- the path to the FDR-corrected p-values
% 
% Updated: 2011-03-25
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'dependent'	, false	, ...
		'invert'	, []	, ...
		'mask'		, []	, ...
		'output'	, []	, ...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

reFSL	= '(_vox_p_)|(_tfce_p_)';

%get the input files
	bCell	= isdir(strPathP);
	if bCell
	%find all FSL p files
		strPathP				= FindFiles(strPathP,reFSL);
		[cDir,cFilePre,cExt]	= cellfun(@(f) PathSplit(f,'favor','nii.gz'),strPathP,'UniformOutput',false);
		
		if isempty(opt.output)
			cFilePre	= cellfun(@(f) strrep(f,'_p_','_fdrcorrp_'),cFilePre,'UniformOutput',false);
			opt.output	= cellfun(@PathUnsplit,cDir,cFilePre,cExt,'UniformOutput',false);
		end
	else
		if isempty(opt.output)
			opt.output	= PathAddSuffix(strPathP,'-fdrcorr','favor','nii.gz');
		end
		
		strPathP	= {strPathP};
	end
	
	strPathPCorr	= ForceCell(opt.output);
%get the mask paths
	opt.mask			= ForceCell(opt.mask);
	[strPathP,opt.mask]	= FillSingletonArrays(strPathP,opt.mask);
	
	[cDirMask,cMaskPre,cMaskExt]	= cellfun(@(f) PathSplit(f,'favor','nii.gz'),opt.mask,'UniformOutput',false);
	[cDirP,cPPre,cPExt]				= cellfun(@(f) PathSplit(f,'favor','nii.gz'),strPathP,'UniformOutput',false);
	cDirMask						= cellfun(@(fm,dm,dp) conditional(~isempty(fm) && isempty(dm),dp,dm),opt.mask,cDirMask,cDirP,'UniformOutput',false);
	cPathMask						= cellfun(@PathUnsplit,cDirMask,cMaskPre,cMaskExt,'UniformOutput',false);
%correct each p
	nPath	= numel(strPathPCorr);
	
	bDo	= opt.force | ~FileExists(strPathPCorr);
	nDo	= sum(bDo);
	
	cPathDoIn	= strPathP(bDo);
	cPathDoOut	= strPathPCorr(bDo);
	cPathDoMask	= cPathMask(bDo);
	
	progress(nDo,'label','FDR-correcting p values','silent',opt.silent);
	for kP=1:nDo
		%load the p values
			nii	= NIfTIRead(cPathDoIn{kP});
			p	= nii.data;
		%invert the p values
			bInvert	= notfalse(opt.invert) || (isempty(opt.invert) & ~isempty(regexp(cPathDoIn{kP},reFSL)));
			if bInvert
				p	= 1-p;
			end
		%load the mask
			if ~isempty(cPathDoMask{kP})
				m	= logical(getfield(NIfTIRead(cPathDoMask{kP}),'data'));
			else
				m	= [];
			end
		%calculate the adjusted p values
			[blah,pCorr]	= fdr(p,0,'mask',m,'dependent',opt.dependent);
		%uninvert
			if bInvert
				pCorr	= 1-pCorr;
			end
		%save the corrected p values
			nii.data	= pCorr;
			NIfTIWrite(nii,cPathDoOut{kP});
		
		progress;
	end
%uncellify
	if ~bCell
		strPathPCorr	= strPathPCorr{1};
	end
	