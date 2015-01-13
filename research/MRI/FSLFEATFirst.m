function [bSuccess,cDirOut] = FSLFEATFirst(cPathData,d,varargin)
% FSLFEATFirst
% 
% Description:	perform a first level analysis of functional data using FSL's
%				feat
% 
% Syntax:	[bSuccess,cDirOut] = FSLFEATFirst(cPathData,d,<options>)
% 
% In:
% 	cPathData			- the path to a functional data file that has already
%						  been preprocessed using FSLFeatPreprocess, or a cell of
%						  paths. feat is called for each data file individually.
%	d					- an nVolume x nEV design matrix, or a cell of ??? x nEV
%						  design matrices
%	<options>:
%		output:			(<auto>) the path to the folder in which to place
%						information about the analysis, or a cell of paths
%		ev_name			(<auto>) a nEV-length cell of names for each
%						explanatory variable in the design matrix
%		convolve:		(false) true to convolve the EVs, or an nEV-length
%						logical array specifying which EVs to convolve with a
%						double-gamma HRF
%		tfilter:		(false) true to temporally filter the EVs, or an
%						nEV-length logical array specifying which EVs to filter
%		tderivative:	(false) true to add the temporal derivative of the EVs as
%						additional EVs, or an nEV-length logical array specifying
%						the EVs for which to add temporal derivatives
%		tcontrast		(eye(nEV)) an nTContrast x nEV array of t-contrast
%						definitions.  FEAT seems to crash if no t-contrasts are
%						defined
%		tcontrast_name	(<auto>) an nTContrast-length cell of names for each
%						t-contrast
%		ftest:			(ones(1,nTContrast)) an nFTest x nTContrast array of
%						f-test definitions
%		delete_volumes:	(0) the number of volumes to delete from the beginning
%						of the data file (design matrix must not include these
%						volumes)
%		highpass:		(100) the highpass filter cutoff used while
%						preprocessing the data, in seconds.  set to 0 if
%						highpass filtering was skipped.
%		lowpass:		(false) true if a lowpass filter was used while
%						preprocessing the data
%		bb_thresh:		(10) the brain/background threshold percentage
%		noise_level:	(0.66) the noise level parameter in the feat design
%		noise_ar:		(0.34) the noise AR parameter in the feat design
%		nthread:		(1) number of threads to use
%		force:			(true) true to reanalyze files that already contain
%						feat outputs
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which data sets were successfully
%				  analyzed
%	cDirOut		- a cell of output directories
% 
% Updated: 2014-12-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'			, []	, ...
		'ev_name'			, []	, ...
		'convolve'			, false	, ...
		'tfilter'			, false	, ...
		'tderivative'		, false	, ...
		'tcontrast'			, []	, ...
		'tcontrast_name'	, []	, ...
		'ftest'				, []	, ...
		'delete_volumes'	, 0		, ...
		'highpass'			, 100	, ...
		'lowpass'			, false	, ...
		'bb_thresh'			, 10	, ...
		'noise_level'		, 0.66	, ...
		'noise_ar'			, 0.34	, ...
		'nthread'			, 1		, ...
		'force'				, true	, ...
		'silent'			, false	  ...
		);

status('preparing FEAT First','silent',opt.silent);

%cellify
	[cPathData,d,bNoCell,dummy]	= ForceCell(cPathData,d); 
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

	if isempty(opt.tcontrast_name)
		opt.tcontrast_name	= arrayfun(@(k) ['tcontrast_' num2str(k)],(1:nTContrast)','UniformOutput',false);
	end
	if isempty(opt.output)
		cDirOut	= cellfun(@FSLDirFEAT,cPathData,'uni',false);
	else
		cDirOut	= ForceCell(opt.output);
	end
	
	[cPathData,cDirOut,d]	= FillSingletonArrays(cPathData,cDirOut,d);
	
	opt.convolve	= repto(reshape(opt.convolve,[],1),[nEV 1]);
	opt.tfilter		= repto(reshape(opt.tfilter,[],1),[nEV 1]);
	opt.tderivative	= repto(reshape(opt.tderivative,[],1),[nEV 1]);
	
	bNoCell	= bNoCell && numel(cPathData)==1;
%get the template
	strPathFEATTemplate	= PathAddSuffix(mfilename('fullpath'),'','template');
	featTemplate		= ReadTemplate(strPathFEATTemplate,'subtemplate',true);
%get the files to analyze
	if ~opt.force
		cPathCheck	= cellfun(@(d) PathUnsplit(DirAppend(d,'stats'),'pe1','nii.gz'),cDirOut,'UniformOutput',false);
		bProcess	= ~FileExists(cPathCheck);
	else
		bProcess	= true(size(cPathData));
	end
%analyze each
	bSuccess	= true(size(cPathData));
	mtO			= MultiTask(@AnalyzeOne,{cPathData(bProcess),d(bProcess),cDirOut(bProcess)},'uniformoutput',true,'description','Analyzing functional data using FEAT','nthread',opt.nthread,'silent',opt.silent);
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
function b = AnalyzeOne(strPathData,d,strDirOut)
	status(sprintf('analyzing %s',strPathData),'silent',opt.silent);

	[strDirData,strFileData]	= PathSplit(strPathData,'favor','nii.gz');
	
	[tr,sNIfTI]	= NIfTIGetTiming(strPathData);
	
	%make sure strDirOut exists
		b	= CreateDirPath(strDirOut);
		if ~b
			return;
		end
	%save the ev files
		cPathEV	= cell(nEV,1);
		for kEV=1:nEV
			cPathEV{kEV}	= GetTempFile('ext','txt');
			fput(array2str(d(:,kEV)),cPathEV{kEV});
		end
	%temporary directory so we're not left with a bunch of crap
		strDirTemp	= GetTempDir;
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
			
			kConvolve		= conditional(opt.convolve(kEV),3,0);
			bTFilter		= opt.tfilter(kEV);
			bTDerivative	= opt.tderivative(kEV);
			
			sEV			= 	struct(...
								'n'						, kEV					, ...
								'name'					, opt.ev_name{kEV}		, ...
								'shape'					, 2						, ...%only implement manually-defined EVs for now
								'convolve'				, kConvolve				, ...
								'convolve_phase'		, 0						, ...%?
								'temporal_filter'		, opt.tfilter(kEV)		, ...
								'temporal_derivative'	, opt.tderivative(kEV)	, ...
								'ev_path'				, cPathEV{kEV}			, ...
								'ev_orthogonalise'		, strEVOrtho			  ...
								);
			cEV{kEV}	= StringFillTemplate(featTemplate('ev'),sEV);
		end
		
		strEV	= join(cEV,10);
	%fill the contrast template
		%fill the t contrast template
			cTContrast	= cell(nTContrast,1);
			
			%get the real contrasts
				nEVReal			= nEV + sum(opt.tderivative);
				
				%assuming all have the derivative
					tContrastReal	= reshape([opt.tcontrast; zeros(size(opt.tcontrast))],nTContrast,[]);
				%now just keep the columns that actually do
					bKeep			= reshape([true(1,nEV); reshape(opt.tderivative,1,[])],1,[]);
					tContrastReal	= tContrastReal(:,bKeep);
			
			for kT=1:nTContrast
				%fill the contrast vector templates
					%real
						cTContrastReal	= cell(nEVReal,1);
						
						for kTE=1:nEVReal
							sContrastVector		= struct(...
													'type'			, 'real'					, ...
													'n_contrast'	, kT						, ...
													'n_element'		, kTE						, ...
													'value'			, tContrastReal(kT,kTE)	  ...
													);
							cTContrastReal{kTE}	= StringFillTemplate(featTemplate('t_contrast_vector'),sContrastVector);
						end
						
						strTContrastReal	= join(cTContrastReal,10);
					%orig
						cTContrastOrig	= cell(nEV,1);
						
						for kTE=1:nEV
							sContrastVector		= struct(...
													'type'			, 'orig'					, ...
													'n_contrast'	, kT						, ...
													'n_element'		, kTE						, ...
													'value'			, opt.tcontrast(kT,kTE)	  ...
													);
							cTContrastOrig{kTE}	= StringFillTemplate(featTemplate('t_contrast_vector'),sContrastVector);
						end
						
						strTContrastOrig	= join(cTContrastOrig,10);
				
				sTContrast		=	struct(...
										'n'							, kT						, ...
										'title'						, opt.tcontrast_name{kT}	, ...
										't_contrast_vector_real'	, strTContrastReal			, ...
										't_contrast_vector_orig'	, strTContrastOrig			  ...
										);
				cTContrast{kT}	= StringFillTemplate(featTemplate('t_contrast'),sTContrast);
			end
			
			strTContrast	= join(cTContrast,10);
		%fill the f-test template
			%fill the f-test vector templates
% 				%real
					cFTestReal	= {};
					for kF=1:nFTest
						for kFE=1:nTContrast
							sFTestVector		= struct(...
													'type'		, 'real'			, ...
													'n_test'	, kF				, ...
													'n_element'	, kFE				, ...
													'value'		, opt.ftest(kF,kFE)	  ...
													);
							cFTestReal{end+1}	= StringFillTemplate(featTemplate('f_test_vector'),sFTestVector);
						end
					end
					
					strFTestReal	= join(cFTestReal,10);
				%orig
					cFTestOrig	= {};
					for kF=1:nFTest
						for kFE=1:nTContrast
							sFTestVector		= struct(...
													'type'		, 'orig'			, ...
													'n_test'	, kF				, ...
													'n_element'	, kFE				, ...
													'value'		, opt.ftest(kF,kFE)	  ...
													);
							cFTestOrig{end+1}	= StringFillTemplate(featTemplate('f_test_vector'),sFTestVector);
						end
					end
					
					strFTestOrig	= join(cFTestOrig,10);
			
			sFTest		= struct(...
							'f_test_vector_real'	, strFTestReal	, ...
							'f_test_vector_orig'	, strFTestOrig	  ...
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
		bHighpass			= opt.highpass~=0;
		
		nEVReal	= nEV + sum(opt.tderivative);
		
		sMain		= struct(...
						'functional_path'	, strPathData			, ...
						'output_dir'		, strDirTemp			, ...
						'tr'				, tr					, ...
						'volumes'			, sNIfTI.nvol			, ...
						'delete_volumes'	, opt.delete_volumes	, ...
						'bb_thresh'			, opt.bb_thresh			, ...
						'noise_level'		, opt.noise_level		, ...
						'noise_ar'			, opt.noise_ar			, ...
						'highpass'			, double(bHighpass)		, ...
						'highpass_cutoff'	, opt.highpass			, ...
						'lowpass'			, opt.lowpass			, ...
						'num_ev_orig'		, nEV					, ...
						'num_ev_real'		, nEVReal				, ...
						'num_tcontrast'		, nTContrast			, ...
						'num_ftest'			, nFTest				, ...
						'ev'				, strEV					, ...
						'contrast'			, strContrast			  ...
						);
		strFEATDef	= StringFillTemplate(featTemplate('main'),sMain);
	%save the feat definition
		strPathFEATDef	= PathUnsplit(strDirOut,['feat-stats-' strFileData],'fsf');
		strPathDesign	= PathUnsplit(strDirOut,'design','fsf');
		
		fput(strFEATDef,strPathFEATDef);
		fput(strFEATDef,strPathDesign);
	%run feat
		[ec,strOutput]	= RunBashScript(['feat ' strPathFEATDef],'silent',opt.silent);
		b				= ec==0;
		
		if ~notfalse(b)
			b	= false;
			return;
		end
		
		strDirFEAT		= DirAppend(strDirTemp,'.feat');
	%copy the data to the output directory
		b	= notfalse(FileCopy(strDirFEAT,strDirOut));
	%remove the temporary directory
		[ec,strOutput]	= RunBashScript(['rm -r ' strDirTemp],'silent',opt.silent);
	%delete the ev files
		cellfun(@delete,cPathEV);
end
%------------------------------------------------------------------------------%

end
