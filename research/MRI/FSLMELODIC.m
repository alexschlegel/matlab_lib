function [comp, weight, cDirOut] = FSLMELODIC(cPathData,varargin)
% FSLMELODIC
% 
% Description:	call FSL's MELODIC tool to perform probabilistic independent
%				components analysis on a set of 4D fMRI NIfTI files
%
% WARNING:	it seems that FSL outputs PCA (and maybe ICA) signals in reversed
%			order, so that the last component in the output is actually the
%			first principal component. beware of that with the comp output from
%			this function.
% 
% Syntax:	[comp, weight, cDirOut] = FSLMELODIC(cPathData,<options>)
% 
% In:
% 	cPathData	- the path or cell of paths to 4D NIfTI data files
%	<options>: see the melodic command line tool for more (and inadequate) help
%				on these options
%		out:			(<auto>) the output directory/cell of directories
%		mask:			(<none>) the path to a NIfTI mask to restrict the ICA
%						calcuation/cell of paths
%		pcaonly:		(false) true to return the PCA components & weights
%		dim:			(<auto>) number of dimensions for the dimension-
%						reduction step
%		dimest:			(<auto>) the estimation technique for automatic
%						dimension reduction
%		mindim:			(<none>) the minimum number of dimensions to return
%		nonlinearity:	(<auto>) the nonlinearity to use
%		bet:			(true) true to BET the data first (if not using a mask).
%						set this to a value to use it as the brain/background
%						threshold.
%		varnorm:		(true) perform variance normalization
%		report:			(false) generate an html report
%		nthread:		(1) the number of threads to use
%		force:			(true) true to force ICA calculation even if the output
%						files already exist
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	comp	- an nSample x nComponent array of PCA/ICA component signals (or a
%			  cell)
%	weight	- a 4D array of the PCA/ICA weights
%	cDirOut	- the output directory / cell of output directories
% 
% Updated: 2014-07-25
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bLoadComp	= nargout>0;
bLoadWeight	= nargout>1;

%format the inputs
	opt	= ParseArgsOpt(varargin,...
			'out'			, []	, ...
			'mask'			, []	, ...
			'pcaonly'		, false	, ...
			'dim'			, []	, ...
			'dimest'		, []	, ...
			'mindim'		, []	, ...
			'nonlinearity'	, []	, ...
			'bet'			, true	, ...
			'varnorm'		, true	, ...
			'report'		, false	, ...
			'nthread'		, 1		, ...
			'force'			, true	, ...
			'silent'		, false	  ...
			);
	
	bCellOut	= iscell(cPathData);
	
	[cPathData,opt.out,opt.mask]	= ForceCell(cPathData,opt.out,opt.mask);
	[cPathData,opt.out,opt.mask]	= FillSingletonArrays(cPathData,opt.out,opt.mask);
	
	sData	= size(cPathData);
	nData	= numel(cPathData);
	
	if ~isempty(opt.dim) && ~isempty(opt.mindim) && opt.dim<opt.mindim
		error('dim option is less than mindim option.');
	end

%analyze!
	cArg	=	{
					cPathData
					opt.mask
					opt.out
				};
	
	[comp, weight, cDirOut]	= MultiTask(@DoMELODIC,cArg,...
										'description'	, 'running MELODIC'	, ...
										'nthread'		, opt.nthread		, ...
										'silent'		, opt.silent		  ...
										);

%uncellify
	if ~bCellOut
		[comp, weight, cDirOut]	= varfun(@(x) x{1}, comp, weight, cDirOut);
	end

%------------------------------------------------------------------------------%
function [comp, weight, strDirOut] = DoMELODIC(strPathData,strPathMask,strDirOut,varargin)
	mnDim	= ParseArgs(varargin,[]);
	
	bForce	= opt.force || ~isempty(mnDim);
	
	strDirOut		= unless(strDirOut, GetOutputDir(strPathData, strPathMask));
	bMask			= ~isempty(strPathMask);
	
	if bForce || ~OutputExists(strDirOut)
		%remove any existing files
			if isdir(strDirOut)
				rmdir(strDirOut,'s');
			end
			
		%construct the MELODIC options
			cInput	= {'-i' strPathData};
			cOutput	= {'-o' strDirOut};
			cMask	= conditional(bMask,{'-m', strPathMask},{});
			
			if ~bMask
				switch class(opt.bet)
					case 'logical'
						cBET	= conditional(opt.bet,{},{'--nomask'});
					otherwise
						cBET	= {sprintf('--bgthreshold=%d',opt.bet)};
				end
			else
				cBET	= {};
			end
			
			if ~isempty(mnDim)
				cDim	= {'-d',num2str(mnDim),'-n',num2str(mnDim)};
				cDimEst	= {};
			else
				cDim	= conditional(opt.dim,{'-d',num2str(opt.dim),'-n',num2str(opt.dim)},{});
				cDimEst	= conditional(opt.dimest,{sprintf('--dimest=%s',opt.dimest)},{});
			end
			
			cNL			= conditional(opt.nonlinearity,{sprintf('--nl=%s',opt.nonlinearity)},{});
			cVarNorm	= conditional(opt.varnorm,{},{'-vn'});
			cReport		= conditional(opt.report,{'--report'},{});
			cPCA		= {'--Opca','--Owhite'};
			
			cOption	= [cInput cOutput cMask cBET cDim cDimEst cNL cVarNorm cReport cPCA];
		%call melodic
			[ec,out]	= CallProcess('melodic',cOption,'silent',true);
			
			if ec
				error(['MELODIC exited with status ' num2str(ec) ': ' out{1}]);
			end
		%make sure the output files were created
			if ~OutputExists(strDirOut)
				error('Output file paths were not created.');
			end
	end
	
	%load the results
		[comp,weight]	= LoadMELODIC(strDirOut);
	
	%did we get the number of dimensions that we need?
		nDim	= size(comp,2);
		if ~isempty(opt.mindim) && nDim<opt.mindim
			if ~isempty(mnDim)
				error('Minimum dimensionality (%d) could not be achieved.', opt.mindim);
			end
			
			status(sprintf('Estimated dimensions (%d) were fewer than minimum (%d) for %s. Rerunning...',nDim,opt.mindim,strPathData),'warning',true,'silent',opt.silent);
			
			[comp, weight, strDirOut] = DoMELODIC(strPathData,strPathMask,strDirOut,opt.mindim);
		end
end
%------------------------------------------------------------------------------%
function b = OutputExists(strDirOut)
	[strPathComp,strPathWeight]	= GetOutputPaths(strDirOut);
	
	b	= FileExists(strPathComp) && FileExists(strPathWeight);
end
%------------------------------------------------------------------------------%
function [comp, weight] = LoadMELODIC(strDirOut)
	[strPathComp,strPathWeight]	= GetOutputPaths(strDirOut);
	
	if bLoadComp
		comp	= str2array(fget(strPathComp));
	else
		comp	= [];
	end
	
	if bLoadWeight
		weight	= getfield(NIfTIRead(strPathWeight),'data');
	else
		weight	= [];
	end
end
%------------------------------------------------------------------------------%
function strDirOut = GetOutputDir(strPathData, strPathMask)
	strDirBase	= PathGetDir(strPathData);
	strDirPre	= PathGetFilePre(strPathData,'favor','nii.gz');
	strDirPost	= conditional(~isempty(strPathMask),['-' PathGetFilePre(strPathMask,'favor','nii.gz')],'');
	
	strDirOut	= DirAppend(strDirBase,[strDirPre strDirPost '.ica']);
end
%------------------------------------------------------------------------------%
function [strPathComp,strPathWeight]	= GetOutputPaths(strDirOut)
	if opt.pcaonly
		strPathComp		= PathUnsplit(strDirOut,'melodic_dewhite');
		strPathWeight	= PathUnsplit(strDirOut,'melodic_pca','nii.gz');
	else
		strPathComp		= PathUnsplit(strDirOut,'melodic_mix');
		strPathWeight	= PathUnsplit(strDirOut,'melodic_IC','nii.gz');
	end
end
%------------------------------------------------------------------------------%

end
