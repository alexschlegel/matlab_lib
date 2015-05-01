function [win,t] = fMRIWindow(cPathFunctional,cOnset,varargin)
% fMRIWindow
% 
% Description:	calculate timecourse windows from fMRI data that have been
%				preprocessed using FSLFEATPreprocess
% 
% Syntax:	[win,t] = fMRIWindow(cPathFunctional,cOnset,<options>)
% 
% In:
%	cPathFunctional	- the path to a functional data file, a cell of paths
%					  (multiple runs), or a cell of cells of paths (multiple runs
%					  of multiple subjects)
%	cOnset			- a cell of onset times (one for each condition), cell of
%					  cells of onset times, or cell of cells of cells of onset
%					  times (in TRs, t==0 for first TR).  each inner cell must
%					  have the same number of conditions.
%	<options>:
%		output:			('%bold') the type of output data.  either 'bold' for raw
%						BOLD values or '%bold' for percent change in BOLD from
%						baseline.
%		mask:			(<'feat-##/reg/mask.nii.gz'>) the path to a mask, a cell
%						of paths to masks, or a cell of cells of paths to masks
%						from which to extract the mean timecourses.  masks are
%						interpreted differently depending on the input functional
%						paths:
%							single path:
%								mask is in same space as functional
%							cell of paths:
%								single mask: mask is in single subject's
%									highres space
%								cell of masks: masks are in same space as
%									functional
%							cell of cells of paths:
%								single mask: mask is in standard space
%								cell of masks: masks are in subjects' highres
%									spaces
%								cell of cells of masks:
%									masks are in same space as functional
%		tr:				(2) the number of seconds per TR
%		win_start:		(-2) the first TR to include in the output, relative to
%						onset
%		win_end:		(<10>) the last TR to include in the output, relative to
%						onset
%		base_start:		(-2) the first TR to use for baseline calculation,
%						relative to onset
%		base_end:		(-1) the last TR to use for baseline calculation,
%						relative to onset
%		cores:		(1) the number of processor cores to use
% 
% Out:
%	win	- an nTimepoint x nCondition x nRep array of timecourse data
% 	t	- an nTimepoint x 1 array of time values (in seconds)
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'		, '%bold'	, ...
		'mask'			, []		, ...
		'tr'			, 2			, ...
		'win_start'		, -2		, ...
		'win_end'		, 10		, ...
		'base_start'	, -2		, ...
		'base_end'		, -1		, ...
		'cores'			, 1			  ...
		);

opt.output	= CheckInput(opt.output,'output',{'%bold','bold'});
strBaseline	= switch2(opt.output,...
				'%bold'	, 'percent'	, ...
				'bold'	, false		  ...
				);

t			= opt.tr*(opt.win_start:opt.win_end)';
nTimepoint	= numel(t);
win			= [];

%parse the data files
	if iscell(cPathFunctional)
		if isempty(cPathFunctional)
			return;
		end
		
		if iscell(cPathFunctional{1})
			if isempty(cPathFunctional{1})
				return;
			end
			
			strTypeInput	= 'experiment';
		else
			strTypeInput	= 'subject';
			
			cPathFunctional	= {cPathFunctional};
			cOnset			= {cOnset};
		end
	else
		strTypeInput	= 'run';
		
		cPathFunctional	= {{cPathFunctional}};
		cOnset			= {{cOnset}};
	end
	
	nCondition	= numel(cOnset{1}{1});
	
	cPathFunctionalAll	= cat(1,cPathFunctional{:});
	cOnsetAll			= cat(1,cOnset{:});
	
	cRun				= cellnestfun(@PathGetRun,cPathFunctional);
	cDirFEAT			= cellnestfun(@(f,r) DirAppend(PathGetDir(f),['feat-' StringFill(r,2)]),cPathFunctional,cRun);
	cPathHighres		= cellnestfun(@(d) PathUnsplit(DirAppend(d,'reg'),'highres','nii.gz'),cDirFEAT);
	cPathExampleFunc	= cellnestfun(@(d) PathUnsplit(DirAppend(d,'reg'),'example_func','nii.gz'),cDirFEAT);
	
	cDirFEATFirst			= cellfun(@(x) x{1},cDirFEAT,'UniformOutput',false);
	cPathHighresFirst		= cellfun(@(x) x{1},cPathHighres,'UniformOutput',false);
	cPathExampleFuncFirst	= cellfun(@(x) x{1},cPathExampleFunc,'UniformOutput',false);
	
	cDirFEATAll			= cat(1,cDirFEAT{:});
	cPathHighresAll		= cat(1,cPathHighres{:});
	cPathExampleFuncAll	= cat(1,cPathExampleFunc{:});
%get the masks in native space
	cPathMaskDefault	= cellnestfun(@(d) PathUnsplit(d,'mask','nii.gz'),cDirFEAT);
	
	if iscell(opt.mask)
	%cell of masks
		if isempty(opt.mask)
		%empty cell, use default
			cPathMask	= cPathMaskDefault;
			strTypeMask	= 'native';
		else
			if iscell(opt.mask{1})
			%cell of cells of masks
				switch strTypeInput
					case 'experiment'
						cPathMask	= opt.mask;
						strTypeMask	= 'native';
					otherwise
						error('Invalid mask input.');
				end
			else
			%single cell of masks
				switch strTypeInput
					case 'experiment'
					%highres space
						cPathMask	= cellfun(@(cf,m) repmat({m},size(cf)),cPathFunctional,opt.mask,'UniformOutput',false);
						strTypeMask	= 'highres';
					case 'subject'
					%native space
						cPathMask	= {opt.mask};
						strTypeMask	= 'native';
					otherwise
						error('Invalid mask input.');
				end
			end
		end
	else
	%single mask
		switch strTypeInput
			case 'experiment'
			%standard space
				cPathMask	= cellfun(@(cf) repmat({opt.mask},size(cf)),cPathFunctional,'UniformOutput',false);
				strTypeMask	= 'standard';
			case 'subject'
			%highres space
				cPathMask	= {repmat({opt.mask},size(cPathFunctional{1}))};
				strTypeMask	= 'highres';
			case 'run'
			%native space
				cPathMask	= {{opt.mask}};
				strTypeMask	= 'native';
		end
	end
	
	cPathMaskFirst	= cellfun(@(x) x{1},cPathMask,'UniformOutput',false);
	cPathMaskAll	= cat(1,cPathMask{:});
	
	switch strTypeMask
		case {'standard','highres'}
			bTransformAll	= ~cellfun(@isempty,cPathMaskAll);
			
			cPathMaskToNative	= cellnestfun(@(d,m) conditional(isempty(m),[],PathUnsplit(DirAppend(d,'reg'),[PathGetFilePre(m,'favor','nii.gz') '-2func'],'nii.gz')),cDirFEAT,cPathMask);
			cPathInvXFM			= cellnestfun(@(d) PathUnsplit(DirAppend(d,'reg'),[strTypeMask '2example_func'],'mat'),cDirFEAT);
			
			cPathMaskToNativeAll	= cat(1,cPathMaskToNative{:});
			cPathInvXFMAll			= cat(1,cPathInvXFM{:});
			
			b	= FSLRegisterFLIRT(cPathMaskAll(bTransformAll),cPathExampleFuncAll(bTransformAll),...
					'output'	, cPathMaskToNativeAll(bTransformAll)	, ...
					'xfm'		, cPathInvXFMAll(bTransformAll)			, ...
					'interp'	, 'nearestneighbour'					, ...
					'force'		, false									, ...
					'cores'		, opt.cores								  ...
					);
			
			if ~all(b)
				error('Could not calculate functional space masks.');
			end
		case 'native'
			cPathMaskToNative	= cPathMask;
	end
	
	bUseDefault				= cellnestfun(@isempty,cPathMaskToNative);
	cPathMaskToNative		= cellnestfun(@(b,fd,f) conditional(b,fd,f),bUseDefault,cPathMaskDefault,cPathMaskToNative);
	cPathMaskToNative		= cellnestfun(@(b,f) conditional(b & ~FileExists(f),[],f),bUseDefault,cPathMaskToNative);
	cPathMaskToNativeAll	= cat(1,cPathMaskToNative{:});

%get each run's mean timecourse
	cWinAll	= MultiTask(@ExtractWin,{cPathFunctionalAll,cOnsetAll,cPathMaskToNativeAll},...
				'description'	, 'Extracting timecourses'	, ...
				'cores'			, opt.cores					  ...
				);
%average
	switch strTypeInput
		case 'experiment'
			cWin	= mat2cell(cWinAll,cellfun(@numel,cPathFunctional),1);
			cWin	= cellfun(@(cw) nanmean(cat(3,cw{:}),3),cWin,'UniformOutput',false);
		case {'subject','run'}
		%nada
			cWin	= cWinAll;
	end
	
	win	= cat(3,cWin{:});


%------------------------------------------------------------------------------%
function win = ExtractWin(strPathFunctional,cOnset,strPathMask)
	%load the data
		d	= NIfTI.Read(strPathFunctional,'return','data');
	%load the mask
		if ~isempty(strPathMask)
			m	= logical(NIfTI.Read(strPathMask,'return','data'));
		else
			m	= true(size(d));
		end
	%extract the windows
		cOnset		= reshape(cOnset,[],1);
		cOnset		= cellfun(@(x) reshape(x,[],1),cOnset,'UniformOutput',false);
		tOnset		= cat(1,cOnset{:});
		[winAll,t2]	= ExtractWindow(d,tOnset,...
						'mask'				, m					, ...
						'start'				, opt.win_start		, ...
						'end'				, opt.win_end		, ...
						'baseline_type'		, strBaseline		, ...
						'baseline_start'	, opt.base_start	, ...
						'baseline_end'		, opt.base_end		  ...
						);
	%reshape
		nOnset			= cellfun(@numel,cOnset);
		kConditionStart	= [0; cumsum(nOnset)] + 1;
		kConditionEnd	= kConditionStart(2:end)-1;
		kConditionStart	= kConditionStart(1:end-1);
		
		win	= zeros(nTimepoint,nCondition);
		
		for kC=1:nCondition
			win(:,kC)	= nanmean(winAll(kConditionStart(kC):kConditionEnd(kC),:),1);
		end
end
%------------------------------------------------------------------------------%

end