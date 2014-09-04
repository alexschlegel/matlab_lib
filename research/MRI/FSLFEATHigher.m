function [bSuccess,cDirOut] = FSLFEATHigher(cDirFEAT,d,varargin)
% FSLFEATHigher
% 
% Description:	perform a higher level analysis of functional data using FSL's
%				feat
% 
% Syntax:	[bSuccess,cDirOut] = FSLFEATHigher(cDirFEAT,d,<options>)
% 
% In:
%	cDirFEAT	- a cell of paths to lower-level FEAT directories, or a cell of
%				  cells of paths. feat is called for each cell of lower-level
%				  FEAT directories.
%	d			- an nFEATDir x nEV design matrix, or a cell of ??? x nEV design
%				  matrices to use a different one for each set of lower-level
%				  FEAT directories
%	<options>:
%		output:			(<'gfeat' in base path of lower-level FEAT directories>)
%						the path to the folder in which to place information
%						about the preprocessing, or a cell of folder names
%		use_cope:		(<all>) a logical array indicating which COPEs from the
%						lower-level analyses to analyze
%		ev_name			(<auto>) a nEV-length cell of names for each
%						explanatory variable in the design matrix
%		tcontrast		(eye(nEV)) an nTContrast x nEV array of t-contrast
%						definitions.  FEAT seems to crash if no t-contrasts are
%						defined.
%		tcontrast_name	(<auto>) an nTContrast-length cell of names for each
%						t-contrast, or a cell of nTContrast-length cells to use
%						a different set of names for each analysis
%		ftest:			(ones(1,nTContrast)) an nFTest x nTContrast array of
%						f-test definitions
%		group:			(<ones>) an nData-length array specifying group
%						membership, or a cell of arrays
%		model:			(2) the model type to use.  one of the following:
%							0:	mixed effects, simple ordinary least squares
%							1:	mixed effects, FLAME 1+2
%							2:	mixed effects, FLAME 1
%							3:	fixed effects
%		thresh_type:	('cluster') the type of thresholding to perform.  one of:
%						'none', 'uncorrected', 'voxel', or 'cluster'.
%		p_thresh:		(0.05) the probability threshold for rendered stat maps
%		z_thresh:		(2.3) the z threshold for clustering
%		reg_standard:	(true) true if data should be registered to standard
%						space
%		nthread:		(1) number of threads to use
%		force:			(true) true to reanalyze if the feat output already
%						exists
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which data sets were successfully
%				  analyzed
%	cDirOut		- a cell of output FEAT directories
% 
% Updated: 2013-10-17
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgsOpt(varargin,...
		'output'			, []		, ...
		'use_cope'			, []		, ...
		'ev_name'			, []		, ...
		'tcontrast'			, []		, ...
		'tcontrast_name'	, []		, ...
		'ftest'				, []		, ...
		'group'				, []		, ...
		'model'				, 2			, ...
		'thresh_type'		, 'cluster'	, ...
		'p_thresh'			, 0.05		, ...
		'z_thresh'			, 2.3		, ...
		'reg_standard'		, true		, ...
		'nthread'			, 1			, ...
		'force'				, true		, ...
		'silent'			, false		  ...
		);

opt.thresh_type	= CheckInput(opt.thresh_type,'thresh_type',{'none','uncorrected','voxel','cluster'});
threshType		= switch2(opt.thresh_type,...
					'none'			, 0	, ...
					'uncorrected'	, 1	, ...
					'voxel'			, 2	, ...
					'cluster'		, 3	  ...
					);

%cellify
	cdfOld							= cDirFEAT;
	[cDirFEAT,opt.tcontrast_name]	= ForceCell(cDirFEAT,opt.tcontrast_name,'level',2);
	
	bNoCell	= ~isequal(cdfOld,cDirFEAT);
	
	[d,opt.group]	= ForceCell(d,opt.group); 

if ~isempty(d)   
	[dummy,nEV]	= size(d{1}); % nEV will be the same for all design matrices
else
    error('Please specifiy a design matrix');
end

%fill in defaults
	if isempty(opt.ev_name)
		opt.ev_name	= arrayfun(@(k) ['ev_' num2str(k)],(1:nEV)','UniformOutput',false);
	end
	
	if isempty(opt.tcontrast)
		opt.tcontrast	= eye(nEV);
	end
	nTContrast	= size(opt.tcontrast,1);
	
	if isempty(opt.ftest)
		opt.ftest	= ones(1,nTContrast);
	end
	nFTest	= size(opt.ftest,1);
	
	if isempty(opt.output)
		cDirOut	= cellfun(@(c) DirAppend(PathGetBase(c),'gfeat'),cDirFEAT,'UniformOutput',false);
	else
		cDirOut	= ForceCell(opt.output);
	end
	
	[cDirFEAT,cDirOut,d,opt.group,opt.tcontrast_name]	= FillSingletonArrays(cDirFEAT,cDirOut,d,opt.group,opt.tcontrast_name);
	
	cTContrastNameDefault	= arrayfun(@(k) ['tcontrast_' num2str(k)],(1:nTContrast)','UniformOutput',false);
	opt.tcontrast_name		= cellfun(@(c) conditional(isequal(c,{[]}),cTContrastNameDefault,c),opt.tcontrast_name,'UniformOutput',false);
	
	opt.group	= cellfun(@(g,d) unless(g,ones(numel(d),1)),opt.group,cDirFEAT,'UniformOutput',false);
	
	bNoCell	= bNoCell && numel(cDirFEAT)==1;
%get the template
	strPathFEATTemplate	= PathAddSuffix(mfilename('fullpath'),'','template');
	featTemplate		= ReadTemplate(strPathFEATTemplate,'subtemplate',true);
%get the files to analyze
	if ~opt.force
		bProcess	= ~cellfun(@(x,d) FSLCompareDesign(x,d,opt.tcontrast,opt.ftest),cDirOut,d);
	else
		bProcess	= true(size(cDirOut));
	end
%analyze each
	bSuccess	= true(size(cDirOut));
	mtO			= MultiTask(@AnalyzeOne,{cDirFEAT(bProcess),d(bProcess),opt.group(bProcess),opt.tcontrast_name(bProcess),cDirOut(bProcess)},'uniformoutput',true,'description','Higher Level FEAT Analysis','nthread',opt.nthread,'silent',opt.silent);
	switch class(mtO)
		case 'cell'
			bSuccess(bProcess)	= cellfun(@notfalse,mtO);
		otherwise
			bSuccess(bProcess)	= mtO;
	end
%uncellify
	if bNoCell
		cDirOut	= cDirOut{1};
	end

%------------------------------------------------------------------------------%
function b = AnalyzeOne(cDirFEAT,d,grp,cTContrastName,strDirOut)
	[nData,nEV]	= size(d);
	
	%make sure we got files
		b	= nData>0;
		if ~b
			return;
		end
	%make sure strDirOut exists
		b	= CreateDirPath(strDirOut);
		if ~b
			return;
		end
	%temporary directory so we're not left with a bunch of crap
		strDirTemp	= GetTempDir;
	%fill the cope template
		if ~isempty(opt.use_cope)
			bUseCope	= reshape(opt.use_cope,[],1);
		else
			bUseCope	= true(numel(FSLPathCOPE(cDirFEAT{1})),1);
		end
		nCope	= numel(bUseCope);
		
		%fill the use_cope template
			cCope	= cell(nCope,1);
			for kC=1:nCope
				sCope		=	struct(...
									'n_cope'	, kC					, ...
									'use'		, double(bUseCope(kC))	  ...
									);
				cCope{kC}	= StringFillTemplate(featTemplate('use_cope'),sCope);
			end
			
			strUseCope	= join(cCope,10);
		
		sCope	= struct(...
					'n_cope'	, nCope			, ...
					'use_cope'	, strUseCope	  ...
					);
		strCope	= StringFillTemplate(featTemplate('cope'),sCope);
	%fill the data_path template
		cDataPath	= cell(nData,1);
		for kD=1:nData
			sData			= struct(...
									'n_path'	, kD			, ...
									'path'		, cDirFEAT{kD}	  ...
									);
			cDataPath{kD}	= StringFillTemplate(featTemplate('data_path'),sData);
		end
		
		strDataPath	= join(cDataPath,10);
	%fill the ev template
		cEV	= cell(nEV,1);
		
		for kEV=1:nEV
			%fill the ev_orthogonalise template
				cEVOrtho	= cell(nEV+1,1);
				
				for kEVO=1:nEV+1
					sEVOrtho		=	struct(...
											'n_ev'		, kEV		, ...
											'n_other'	, kEVO-1	  ...
											);
					cEVOrtho{kEVO}	= StringFillTemplate(featTemplate('ev_orthogonalise'),sEVOrtho);
				end
				
				strEVOrtho	= join(cEVOrtho,10);
			%fill the ev_value template
				cEVValue	= cell(nData,1);
				
				for kD=1:nData
					sEVValue		= struct(...
										'n_ev'		, kEV		, ...
										'n_input'	, kD		, ...
										'value'		, d(kD,kEV)	  ...
										);
					cEVValue{kD}	= StringFillTemplate(featTemplate('ev_value'),sEVValue);
				end
				
				strEVValue	= join(cEVValue,10);
			
			sEV			= 	struct(...
								'n'						, kEV					, ...
								'name'					, opt.ev_name{kEV}		, ...
								'ev_orthogonalise'		, strEVOrtho			, ...
								'ev_value'				, strEVValue			  ...
								);
			cEV{kEV}	= StringFillTemplate(featTemplate('ev'),sEV);
		end
		
		strEV	= join(cEV,10);
	%fill the group template
		cGroup	= cell(nData,1);
		
		for kD=1:nData
			sGroup		= struct(...
							'n_input'	, kD		, ...
							'n_group'	, grp(kD)	  ...
							);
			cGroup{kD}	= StringFillTemplate(featTemplate('group'),sGroup);
		end
		
		strGroup	= join(cGroup,10);
	%fill the contrast template
		%fill the t contrast template
			cTContrast	= cell(nTContrast,1);
			
			for kT=1:nTContrast
				%fill the contrast vector template
					cTContrastVector	= cell(nEV,1);
					
					for kTE=1:nEV
						sContrastVector			= struct(...
													'n_contrast'	, kT						, ...
													'n_element'		, kTE						, ...
													'value'			, opt.tcontrast(kT,kTE)	  ...
													);
						cTContrastVector{kTE}	= StringFillTemplate(featTemplate('t_contrast_vector'),sContrastVector);
					end
					
					strTContrastVector	= join(cTContrastVector,10);
				
				sTContrast		=	struct(...
										'n'					, kT					, ...
										'title'				, cTContrastName{kT}	, ...
										't_contrast_vector'	, strTContrastVector	  ...
										);
				cTContrast{kT}	= StringFillTemplate(featTemplate('t_contrast'),sTContrast);
			end
			
			strTContrast	= join(cTContrast,10);
		%fill the f-test template
			%fill the f-test vector templates
				cFTestVector	= {};
				for kF=1:nFTest
					for kFT=1:nTContrast
						sFTestVector		= struct(...
												'n_test'	, kF				, ...
												'n_element'	, kFT				, ...
												'value'		, opt.ftest(kF,kFT)	  ...
												);
						cFTestVector{end+1}	= StringFillTemplate(featTemplate('f_test_vector'),sFTestVector);
					end
				end
				
				strFTestVector	= join(cFTestVector,10);
			
			sFTest		= struct(...
							'f_test_vector'	, strFTestVector	  ...
							);
			strFTest	= StringFillTemplate(featTemplate('f_test'),sFTest);
		%fill the contrast mask template
			cContrastMask	= {};
			nContrastMask	= nTContrast + nFTest;
			for kC1=1:nContrastMask
				for kC2=1:nContrastMask
					if kC1~=kC2
						sContrastMask			= struct(...
													'n1'	, kC1	, ...
													'n2'	, kC2	  ...
													);
						cContrastMask{end+1}	= StringFillTemplate(featTemplate('contrast_mask'),sContrastMask);
					end
				end
			end
			
			strContrastMask	= join(cContrastMask,10);
		
		sContrast	=	struct(...
							't_contrast'	, strTContrast		, ...
							'f_test'		, strFTest			, ...
							'contrast_mask'	, strContrastMask	  ...
							);
		strContrast	= StringFillTemplate(featTemplate('contrast'),sContrast);
	%fill the main template
		sMain		= struct(...
						'output_dir'	, strDirTemp				, ...
						'n_input'		, nData						, ...
						'model'			, opt.model					, ...
						'num_ev'		, nEV						, ...
						'num_tcontrast'	, nTContrast				, ...
						'num_ftest'		, nFTest					, ...
						'thresh_type'	, threshType				, ...
						'p_thresh'		, opt.p_thresh				, ...
						'z_thresh'		, opt.z_thresh				, ...
						'reg_standard'	, double(opt.reg_standard)	, ...
						'cope'			, strCope					, ...
						'data_path'		, strDataPath				, ...
						'ev'			, strEV						, ...
						'group'			, strGroup					, ...
						'contrast'		, strContrast				  ...
						);
		strFEATDef	= StringFillTemplate(featTemplate('main'),sMain);
	%save the feat definition
		strPathDesign	= PathUnsplit(strDirOut,'design','fsf');
		
		fput(strFEATDef,strPathDesign);
	%run feat
		[ec,strOutput]	= RunBashScript(['feat ' strPathDesign],'silent',opt.silent);
		b				= ec==0;
		
		if ~notfalse(b)
			b	= false;
			return;
		end
		
		strDirFEAT		= DirAppend(strDirTemp,'.gfeat');
	%copy the data to the output directory
		b	= notfalse(FileCopy(strDirFEAT,strDirOut));
	%remove the temporary directory
		[ec,strOutput]	= RunBashScript(['rm -r ' strDirTemp],'silent',opt.silent);
end
%------------------------------------------------------------------------------%

end
