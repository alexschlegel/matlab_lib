function [bSuccess,cDirOut] = FSLFEATHigher(cPathIn,d,varargin)
% FSLFEATHigher
% 
% Description:	perform a higher level analysis of functional data using FSL's
%				feat
% 
% Syntax:	[bSuccess,cDirOut] = FSLFEATHigher(cPathIn,d,<options>)
% 
% In:
%	cPathIn		- either a cell of paths to lower-level FEAT directories or a
%				  cell of paths to COPE images from FEAT directories, or a
%				  cell of cells of such paths. feat is called for each cell of
%				  lower-level FEAT directories / COPE files.
%	d			- an nInput x nEV design matrix, or a cell of design matrices to
%				  use a different one for each set of inputs
%	<options>:
%		output:			(<'gfeat' in base path of inputs>) the path to the
%						directory in which to store outputs, or a cell of paths
%		use_cope:		(<all>) a logical array indicating which COPEs from the
%						lower-level analyses to analyze, or a cell of arrays
%						(only applies to lower-level FEAT directory inputs)
%		ev_name			(<auto>) an nEV-length cell of names for each
%						explanatory variable in the design matrix, or a cell of
%						cells to use a different set of names for each design
%						matrix
%		tcontrast		(eye(nEV)) an nTContrast x nEV array of t-contrast
%						definitions, or a cell of t-contrasts. FEAT seems to
%						crash if no t-contrasts are defined.
%		tcontrast_name	(<auto>) an nTContrast-length cell of names for each
%						t-contrast, or a cell of nTContrast-length cells to use
%						a different set of names for each analysis
%		ftest:			(ones(1,nTContrast)) an nFTest x nTContrast array of
%						f-test definitions, or a cell of f-tests
%		group:			(<ones>) an nData-length array specifying group
%						membership, or a cell of group membership arrays
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
%		cores:			(1) the number of processor cores to use
%		force:			(true) true to reanalyze if the feat output already
%						exists
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which data sets were successfully
%				  analyzed
%	cDirOut		- a cell of output FEAT directories
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%process the inputs
	opt	= ParseArgs(varargin,...
			'output'			, []		, ...
			'use_cope'			, []		, ...
			'ev_name'			, {}		, ...
			'tcontrast'			, []		, ...
			'tcontrast_name'	, {}		, ...
			'ftest'				, []		, ...
			'group'				, []		, ...
			'model'				, 2			, ...
			'thresh_type'		, 'cluster'	, ...
			'p_thresh'			, 0.05		, ...
			'z_thresh'			, 2.3		, ...
			'reg_standard'		, true		, ...
			'cores'				, 1			, ...
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
	
	%cellify and fill
		cPathInOrig										= cPathIn;
		[cPathIn,cEVName,cTContrastName]				= ForceCell(cPathIn,opt.ev_name,opt.tcontrast_name,'level',2);
		[d,cDirOut,cUseCOPE,cTContrast,cFTest,cGroup]	= ForceCell(d,opt.output,opt.use_cope,opt.tcontrast,opt.ftest,opt.group);
		
		bNoCell	= ~isequal(cPathInOrig,cPathIn);
		
		[cPathIn,cEVName,cTContrastName,d,cDirOut,cUseCOPE,cTContrast,cFTest,cGroup]	= FillSingletonArrays(cPathIn,cEVName,cTContrastName,d,cDirOut,cUseCOPE,cTContrast,cFTest,cGroup);
		
		bNoCell	= bNoCell && numel(cPathIn)==1;
	%fill in defaults
		[nInput,nEV]	= cellfun(@size,d,'uni',false);
		
		cDirOut	= cellfun(@(p,d) unless(d,DirAppend(PathGetBase(p),'gfeat')),cPathIn,cDirOut,'uni',false);
		
		cEVName			= cellfun(@(evn,nev) unless(evn,arrayfun(@(k) sprintf('ev_%d',k),(1:nev)','uni',false)),cEVName,nEV,'uni',false);
		cTContrast		= cellfun(@(tc,nev) unless(tc,eye(nev)),cTContrast,nEV,'uni',false);
		cTContrastName	= cellfun(@(tcn,tc) unless(tcn,arrayfun(@(k) sprintf('tcontrast_%d',k),(1:size(tc,1))','uni',false)),cTContrastName,cTContrast,'uni',false);
		cFTest			= cellfun(@(ft,tc) unless(ft,ones(1,size(tc,1))),cFTest,cTContrast,'uni',false);
		cGroup			= cellfun(@(g,ni) unless(g,ones(ni,1)),cGroup,nInput,'uni',false);

%get the template
	strPathFEATTemplate	= PathAddSuffix(mfilename('fullpath'),'','template');
	featTemplate		= ReadTemplate(strPathFEATTemplate,'subtemplate',true);
%get the files to analyze
	if ~opt.force
		bProcess	= ~cellfun(@FSLCompareDesign,cDirOut,d,cTContrast,cFTest);
	else
		bProcess	= true(size(cDirOut));
	end
%analyze each
	if any(bProcess(:))
		bSuccess	= true(size(cDirOut));
		cInput		=	{
							cPathIn(bProcess)
							d(bProcess)
							cUseCOPE(bProcess)
							cEVName(bProcess)
							cTContrast(bProcess)
							cTContrastName(bProcess)
							cFTest(bProcess)
							cGroup(bProcess)
							cDirOut(bProcess)
						};
		res			= MultiTask(@AnalyzeOne,cInput,...
						'description'	, 'Higher level FEAT analysis'	, ...
						'uniformoutput'	, true							, ...
						'cores'			, opt.cores						, ...
						'silent'		, opt.silent					  ...
						);
		switch class(res)
			case 'cell'
				bSuccess(bProcess)	= cellfun(@notfalse,res);
			otherwise
				bSuccess(bProcess)	= res;
		end
	end
%uncellify
	if bNoCell
		cDirOut	= cDirOut{1};
	end

%------------------------------------------------------------------------------%
function b = AnalyzeOne(cPathIn,d,bUseCOPE,cEVName,tContrast,cTContrastName,fTest,grp,strDirOut)
	[nData,nEV]	= size(d);
	
	b	= false;
	
	%make sure we got files
		if ~nData>0
			return;
		end
	%make sure strDirOut exists
		if ~CreateDirPath(strDirOut)
			return;
		end
	%temporary directory so we're not left with a bunch of crap
		strDirTemp	= GetTempDir;
	
	%are these FEAT directories or COPE files?
		bFEATDir	= all(cellfun(@isdir,cPathIn));
		inputType	= conditional(bFEATDir,1,2);
	%fill the cope template
		if bFEATDir
			if isempty(bUseCope)
				nCOPE		= numel(FSLPathCOPE(cPathIn{1}));
				bUseCOPE	= true(nCope,1);
			else
				bUseCOPE	= reshape(bUseCope,[],1);
			end
			nCOPE	= numel(bUseCOPE);
			
			%fill the use_cope template
				cUseCOPETemplate	= cell(nCOPE,1);
				for kC=1:nCOPE
					sCOPE	=	struct(...
									'n_cope'	, kC					, ...
									'use'		, double(bUseCOPE(kC))	  ...
									);
					
					cUseCOPETemplate{kC}	= StringFillTemplate(featTemplate('use_cope'),sCOPE);
				end
				
				strUseCOPE	= join(cUseCOPETemplate,10);
			
			sCOPE	= struct(...
						'n_cope'	, nCOPE			, ...
						'use_cope'	, strUseCOPE	  ...
						);
		else
			sCOPE	= struct(...
						'n_cope'	, 0		, ...
						'use_cope'	, ''	  ...
						);
		end
		
		strCOPE	= StringFillTemplate(featTemplate('cope'),sCOPE);
	%fill the data_path template
		cDataPathTemplate	= cell(nData,1);
		for kD=1:nData
			sData	= struct(...
							'k_path'	, kD			, ...
							'path'		, cPathIn{kD}	  ...
							);
			
			cDataPathTemplate{kD}	= StringFillTemplate(featTemplate('data_path'),sData);
		end
		
		strDataPath	= join(cDataPathTemplate,10);
	%fill the ev template
		cEVTemplate	= cell(nEV,1);
		
		for kEV=1:nEV
			%fill the ev_orthogonalise template
				cEVOrthoTemplate	= cell(nEV+1,1);
				
				for kEVO=1:nEV+1
					sEVOrtho	=	struct(...
										'n_ev'		, kEV		, ...
										'n_other'	, kEVO-1	  ...
										);
					
					cEVOrthoTemplate{kEVO}	= StringFillTemplate(featTemplate('ev_orthogonalise'),sEVOrtho);
				end
				
				strEVOrtho	= join(cEVOrthoTemplate,10);
			%fill the ev_value template
				cEVValueTemplate	= cell(nData,1);
				
				for kD=1:nData
					sEVValue	= struct(...
									'n_ev'		, kEV		, ...
									'n_input'	, kD		, ...
									'value'		, d(kD,kEV)	  ...
									);
					
					cEVValueTemplate{kD}	= StringFillTemplate(featTemplate('ev_value'),sEVValue);
				end
				
				strEVValue	= join(cEVValueTemplate,10);
			
			sEV	= 	struct(...
						'n'						, kEV				, ...
						'name'					, cEVName{kEV}		, ...
						'ev_orthogonalise'		, strEVOrtho		, ...
						'ev_value'				, strEVValue		  ...
						);
			
			cEVTemplate{kEV}	= StringFillTemplate(featTemplate('ev'),sEV);
		end
		
		strEV	= join(cEVTemplate,10);
	%fill the group template
		cGroupTemplate	= cell(nData,1);
		
		for kD=1:nData
			sGroup	= struct(...
						'n_input'	, kD		, ...
						'n_group'	, grp(kD)	  ...
						);
			
			cGroupTemplate{kD}	= StringFillTemplate(featTemplate('group'),sGroup);
		end
		
		strGroup	= join(cGroupTemplate,10);
	%fill the contrast template
		%fill the t contrast template
			nTContrast			= size(tContrast,1);
			cTContrastTemplate	= cell(nTContrast,1);
			
			for kT=1:nTContrast
				%fill the contrast vector template
					cTContrastVectorTemplate	= cell(nEV,1);
					
					for kTE=1:nEV
						sContrastVector	= struct(...
											'n_contrast'	, kT				, ...
											'n_element'		, kTE				, ...
											'value'			, tContrast(kT,kTE)	  ...
											);
						
						cTContrastVectorTemplate{kTE}	= StringFillTemplate(featTemplate('t_contrast_vector'),sContrastVector);
					end
					
					strTContrastVector	= join(cTContrastVectorTemplate,10);
				
				sTContrast	=	struct(...
									'n'					, kT					, ...
									'title'				, cTContrastName{kT}	, ...
									't_contrast_vector'	, strTContrastVector	  ...
									);
				
				cTContrastTemplate{kT}	= StringFillTemplate(featTemplate('t_contrast'),sTContrast);
			end
			
			strTContrast	= join(cTContrastTemplate,10);
		%fill the f-test template
			%fill the f-test vector templates
				nFTest					= size(fTest,1);
				cFTestVectorTemplate	= cell(nFTest*nTContrast,1);
				
				kFT	= 0;
				for kF=1:nFTest
					for kT=1:nTContrast
						kFT	= kFT + 1;
						
						sFTestVector	= struct(...
											'n_test'	, kF			, ...
											'n_element'	, kT			, ...
											'value'		, fTest(kF,kT)	  ...
											);
						
						cFTestVectorTemplate{kFT}	= StringFillTemplate(featTemplate('f_test_vector'),sFTestVector);
					end
				end
				
				strFTestVector	= join(cFTestVectorTemplate,10);
			
			sFTest		= struct(...
							'f_test_vector'	, strFTestVector	  ...
							);
			strFTest	= StringFillTemplate(featTemplate('f_test'),sFTest);
		%fill the contrast mask template
			nContrastMask			= nTContrast + nFTest;
			cContrastMaskTemplate	= cell(nContrastMask.^2 - nContrastMask);
			
			kC	= 0;
			for kC1=1:nContrastMask
				for kC2=1:nContrastMask
					if kC1~=kC2
						kC	= kC + 1;
						
						sContrastMask	= struct(...
											'n1'	, kC1	, ...
											'n2'	, kC2	  ...
											);
						
						cContrastMaskTemplate{kC}	= StringFillTemplate(featTemplate('contrast_mask'),sContrastMask);
					end
				end
			end
			
			strContrastMask	= join(cContrastMaskTemplate,10);
		
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
						'input_type'	, inputType					, ...
						'model'			, opt.model					, ...
						'num_ev'		, nEV						, ...
						'num_tcontrast'	, nTContrast				, ...
						'num_ftest'		, nFTest					, ...
						'thresh_type'	, threshType				, ...
						'p_thresh'		, opt.p_thresh				, ...
						'z_thresh'		, opt.z_thresh				, ...
						'reg_standard'	, double(opt.reg_standard)	, ...
						'cope'			, strCOPE					, ...
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
