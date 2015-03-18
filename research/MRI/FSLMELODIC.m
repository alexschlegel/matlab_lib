function sOut = FSLMELODIC(varargin)
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
% Syntax:	s = FSLMELODIC(<options>)
% 
% In:
% 	cPathData	- the path or cell of paths to 4D NIfTI data files
%	<options>: see the melodic command line tool for more (and inadequate) help
%				on these options
%		<+ options for MRIParseDataPaths> (use masks option to restrict melodic
%			computation to ROIs)
%		dir_out:		(<auto>) the output directory/cell of directories
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
%		load_comp:		(false) load the component signals if they wouldn't have
%						been loaded otherwise
%		load_weight:	(false) load the weights
%		nthread:		(1) the number of threads to use
%		force:			(true) true to force ICA calculation even if the output
%						files already exist
%		silent:			(false) true to suppress status messages
% 
% Out:
%	s	- a struct of results:
%			comp:		an nSample x nComponent array of PCA/ICA component
%						signals, or a cell of such
%			weight:		a 4D array of the PCA/ICA weights for each component, or
%						a cell of such
%			dir_out:	the output directory(ies)
%			path_data:	the output data path(s)
% 
% Updated: 2015-03-18
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
%format the inputs
	opt	= ParseArgs(varargin,...
			'dir_out'		, []	, ...
			'pcaonly'		, false	, ...
			'dim'			, []	, ...
			'dimest'		, []	, ...
			'mindim'		, []	, ...
			'nonlinearity'	, []	, ...
			'bet'			, true	, ...
			'varnorm'		, true	, ...
			'report'		, false	, ...
			'load_comp'		, false	, ...
			'load_weight'	, false	, ...
			'nthread'		, 1		, ...
			'force'			, true	, ...
			'silent'		, false	  ...
			);
	
	assert(isempty(opt.dim) || isempty(opt.mindim) || opt.dim<opt.mindim,'dim option is less than mindim option.');
	
	opt_path	= optreplace(opt.opt_extra,...
					'require'	, {'functional'}	  ...
					);
	sPath		= ParseMRIDataPaths(opt_path);
	
	cPathData	= sPath.functional;
	sData		= size(cPathData);
	cPathMask	= repto(ForceCell(unless(sPath.mask,[])),sData);
	cDirOut		= repto(ForceCell(opt.dir_out),sData);
	cDirOut		= cellfun(@ParseOutputDir,cDirOut,cPathData,cPathMask,'uni',false); 

%MELODIC!
	sOut	= size(cDirOut);
	
	%determine which data need to be computed
		if opt.force
			bDo	= true(sOut);
		else
			if numel(cDirOut)>0 && iscell(cDirOut{1})
				bDo	= cellfun(@(co) ~all(cellfun(@OutputExists,co)),cDirOut);
			else
				bDo	= ~cellfun(@OutputExists,cDirOut);
			end
		end
	
	%load the existing results
		sOut		= cell(sOut);
		sOut(~bDo)	= cellfunprogress(@LoadResults,cDirOut(~bDo),...
						'label'	, 'loading existing results'	, ...
						'uni'	, false							  ...
						);
	
	%compute the new results
		if any(bDo)
			sOut(bDo)	= MultiTask(@DoMELODIC,{cPathData(bDo) cPathMask(bDo) cDirOut(bDo)},...
							'description'	, 'running MELODIC'	, ...
							'nthread'		, opt.nthread		, ...
							'silent'		, opt.silent		  ...
							);
		end
	
	sOut	= restruct(sOut);
	
%format the output
	if ~sPath.cell_input.mask_inner
		sOut	= structfun2(@cellnestflatten,sOut);
	end
		
	if ~sPath.cell_input.functional
		sOut	= structfun2(@(x) x{1},sOut);
	end

%------------------------------------------------------------------------------%
function s = DoMELODIC(strPathData,strPathMask,strDirOut,varargin)
	if iscell(strPathMask)
		s	= cellfunprogress(@(m,o) DoMELODIC(strPathData,m,o),strPathMask,strDirOut,...
				'uni'	, false								, ...
				'label'	, 'running MELODIC for one dataset'	  ...
				);
		return;
	end
	
	mnDim	= ParseArgs(varargin,[]);
	
	if opt.force || ~isempty(mnDim) || ~OutputExists(strDirOut)
		%remove any existing files
			if isdir(strDirOut)
				rmdir(strDirOut,'s');
			end
			
		%construct the MELODIC options
			bMask	= ~isempty(strPathMask);
		
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
			
			assert(~ec,'MELODIC exited with status %d: %s',ec,out{1});
		%construct the output data files
			comp	= ConstructOutputDatasets(strDirOut);
		%make sure the output files were created
			assert(OutputExists(strDirOut),'output file paths were not created.');
	else
		comp	= [];
	end
	
	%construct the outputs
		s	= LoadResults(strDirOut,comp);
	
	%did we get the number of dimensions that we need?
		nDim	= size(s.comp,2);
		if ~isempty(opt.mindim) && nDim<opt.mindim
			assert(isempty(mnDim),'minimimum dimensionality (%d) could not be achieved for %s.',opt.mindim,strPathData);
			
			status(sprintf('Estimated dimensions (%d) were fewer than minimum (%d) for %s. Rerunning...',nDim,opt.mindim,strPathData),'warning',true,'silent',opt.silent);
			
			s	= DoMELODIC(strPathData,strPathMask,strDirOut,opt.mindim);
		end
end
%------------------------------------------------------------------------------%
function strDirOut = ParseOutputDir(strDirOut, strPathData, strPathMask)
	if iscell(strPathMask) && ~isempty(strPathMask)
		strDirOut	= repto(ForceCell(strDirOut),size(strPathMask)); 
		strDirOut	= cellfun(@(o,m) ParseOutputDir(o,strPathData,m),strDirOut,strPathMask,'uni',false);
		return;
	elseif isempty(strDirOut)
		strDirBase	= PathGetDir(strPathData);
		strDirPre	= PathGetFilePre(strPathData,'favor','nii.gz');
		strDirPost	= '';
		if ~isempty(strPathMask)
			strDirPost	= [strDirPost sprintf('-%s',PathGetFilePre(strPathMask,'favor','nii.gz'))];
		end
		if ~isempty(opt.dim)
			strDirPost	= [strDirPost sprintf('-%d',opt.dim)];
		end
		
		strDirOut	= DirAppend(strDirBase,sprintf('%s%s.ica',strDirPre,strDirPost));
	end
end
%------------------------------------------------------------------------------%
function b = OutputExists(strDirOut)
	sp	= GetOutputPaths(strDirOut);
	b	= all(FileExists(struct2cell(sp)));
end
%------------------------------------------------------------------------------%
function c = ConstructOutputDatasets(strDirOut)
	cType	= {'pca';'ica'};
	nType	= numel(cType);
	
	strTypeRet	= conditional(opt.pcaonly,'pca','ica');
	
	for kT=1:nType
		strType	= cType{kT};
		
		%get the current component path
			sp	= GetOutputPaths(strDirOut,strType);
			
			if ~FileExists(sp.comp)
				return;
			end
		
		%load the component
			comp	= LoadComp(sp.comp);
			
			if strcmp(strType,strTypeRet)
				c	= comp;
			end
		
		%reshape to nFeature x 1 x 1 x nSample
			comp	= permute(comp,[2 3 4 1]);
		
		%construct a NIfTI dataset
			nii	= make_nii(comp);
		
		%save it
			NIfTIWrite(nii,sp.comp_dataset);
	end
end
%------------------------------------------------------------------------------%
function s = LoadResults(strDirOut,varargin)
	if iscell(strDirOut)
		s	= cellfun(@LoadResults,strDirOut,'uni',false);
		return;
	end
	
	sp	= GetOutputPaths(strDirOut);
	
	comp	= ParseArgs(varargin,[]);
	if isempty(comp) && opt.load_comp
		comp	= LoadComp(sp.comp);
	end
	
	if opt.load_weight
		weight	= LoadWeight(sp.weight);
	else
		weight	= [];
	end
	
	s	= struct(...
			'comp'		, comp				, ...
			'weight'	, weight			, ...
			'dir_out'	, strDirOut			, ...
			'path_data'	, sp.comp_dataset	  ...
			);
end
%------------------------------------------------------------------------------%
function comp = LoadComp(strPathComp)
	comp	= str2array(fget(strPathComp));
end
%------------------------------------------------------------------------------%
function weight = LoadWeight(strPathWeight)
	weight	= getfield(NIfTIRead(strPathWeight),'data');
end
%------------------------------------------------------------------------------%
function sp	= GetOutputPaths(strDirOut,varargin)
	strType	= ParseArgs(varargin,conditional(opt.pcaonly,'pca','ica'));
	
	switch strType
		case 'pca'
			sp.comp			= PathUnsplit(strDirOut,'melodic_dewhite');
			sp.comp_dataset	= PathUnsplit(strDirOut,'data_pca','nii.gz');
			sp.weight		= PathUnsplit(strDirOut,'melodic_pca','nii.gz');
		case 'ica'
			sp.comp			= PathUnsplit(strDirOut,'melodic_mix');
			sp.comp_dataset	= PathUnsplit(strDirOut,'data_ica','nii.gz');
			sp.weight		= PathUnsplit(strDirOut,'melodic_IC','nii.gz');
	end
end
%------------------------------------------------------------------------------%

end
