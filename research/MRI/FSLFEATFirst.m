function [b,cDirOut] = FSLFEATFirst(cPathData,d,varargin)
% FSLFEATFirst
% 
% Description:	perform a first level analysis of functional data using FSL's
%				feat
% 
% Syntax:	[b,cDirOut] = FSLFEATFirst(cPathData,d,<options>)
% 
% In:
% 	cPathData			- the path to a functional data file that has already
%						  been preprocessed using FSLFeatPreprocess, or a cell
%						  of paths. feat is called for each data file
%						  individually.
%	d					- an nVolume x nEV design matrix, or a cell of ??? x nEV
%						  design matrices. nEV must be the same for each design
%						  matrix.
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
%		tderivative:	(false) true to add the temporal derivative of the EVs
%						as additional EVs, or an nEV-length logical array
%						specifying the EVs for which to add temporal derivatives
%		tcontrast		(eye(nEV)) an nTContrast x nEV array of t-contrast
%						definitions. FEAT seems to crash if no t-contrasts are
%						defined.
%		tcontrast_name	(<auto>) an nTContrast-length cell of names for each
%						t-contrast
%		ftest:			(ones(1,nTContrast)) an nFTest x nTContrast array of
%						f-test definitions
%		delete_volumes:	(0) the number of volumes to delete from the beginning
%						of the data file (design matrix must not include these
%						volumes)
%		highpass:		(100) the highpass filter cutoff used while
%						preprocessing the data, in seconds. set to 0 if
%						highpass filtering was skipped.
%		lowpass:		(false) true if a lowpass filter was used while
%						preprocessing the data
%		bb_thresh:		(10) the brain/background threshold percentage
%		noise_level:	(0.66) the noise level parameter in the feat design
%		noise_ar:		(0.34) the noise AR parameter in the feat design
%		cores:			(1) the number of processor cores to use
%		force:			(true) true to reanalyze files that already contain
%						feat outputs
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	b		- a logical array indicating which data sets were successfully
%			  analyzed
%	cDirOut	- a cell of output directories
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%process the inputs
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
			'cores'				, 1		, ...
			'force'				, true	, ...
			'silent'			, false	  ...
			);
	
	[cPathData,d,cDirOut,bNoCell,dummy,dummy]	= ForceCell(cPathData,d,opt.output);
	[cPathData,d,cDirOut]						= FillSingletonArrays(cPathData,d,cDirOut);
	
	bNoCell	= bNoCell && numel(cPathData)==1;
	
	%number of EVs
		nEV	= cellfun(@(x) size(x,2),d);
		
		assert(uniform(nEV),'each design matrix must have the same number of EVs.');
		
		nEV	= nEV(1);

	%fill in defaults
		%EV name
			if isempty(opt.ev_name)
				kEV			= (1:nEV)';
				opt.ev_name	= arrayfun(@(k) sprintf('ev_%d',k),kEV,'uni',false);
			end
		
		%T-contrast
			opt.tcontrast	= unless(opt.tcontrast,eye(nEV));
			nTContrast		= size(opt.tcontrast,1);
			
			if isempty(opt.tcontrast_name)
				kTContrast			= (1:nTContrast)';
				opt.tcontrast_name	= arrayfun(@(k) sprintf('tcontrast_%d',k),kTContrast,'uni',false);
			end
		
		%F-test
			opt.ftest	= unless(opt.ftest,ones(1,nTContrast));
		
		%output folder
			cDirOut	= cellfun(@(f,d) unless(d,FSLDirFEAT(f)),cPathData,cDirOut,'uni',false);
		
		opt.convolve	= repto(reshape(opt.convolve,[],1),[nEV 1]);
		opt.tfilter		= repto(reshape(opt.tfilter,[],1),[nEV 1]);
		opt.tderivative	= repto(reshape(opt.tderivative,[],1),[nEV 1]);

%get the files to analyze
	n	= numel(cPathData);
	sz	= size(cPathData);
	
	if opt.force
		bProcess	= true(sz);
	else
		cPathCheck	= cellfun(@(d) PathUnsplit(DirAppend(d,'stats'),'pe1','nii.gz'),cDirOut,'uni',false);
		bProcess	= ~FileExists(cPathCheck);
	end

%analyze each
	b	= true(sz);
	
	param	= rmfield(opt,{'output','cores','force','opt_extra'});
	
	cInput	=	{
					cPathData(bProcess)
					d(bProcess)
					cDirOut(bProcess)
					param
				};
	
	out	= MultiTask(@AnalyzeOne,cInput,...
			'description'	, 'performing first-level FEAT analysis'	, ...
			'cores'			, opt.cores									, ...
			'silent'		, opt.silent								  ...
			);
	
	b(bProcess)	= cellfun(@notfalse,out);

%uncellify
	if bNoCell
		cDirOut	= cDirOut{1};
	end

%------------------------------------------------------------------------------%
function b = AnalyzeOne(strPathData,d,strDirOut,param)
	b	= false;
	
	status(sprintf('analyzing %s',strPathData),'silent',param.silent);
	
	%get the template
		strPathFEATTemplate	= PathAddSuffix(mfilename('fullpath'),'','template');
		param.template		= ReadTemplate(strPathFEATTemplate,'subtemplate',true);
	
	strFileData	= PathGetFilePre(strPathData,'favor','nii.gz');
	
	hdr		= NIfTI.ReadHeader(strPathData);
	nVol	= hdr.dim(5);
	tr		= hdr.pixdim(5);
	
	nEV			= size(d,2);
	nTContrast	= size(param.tcontrast,1);
	nFTest		= size(param.ftest,1);
	
	%make sure strDirOut exists
		if ~CreateDirPath(strDirOut)
			warning('output directory %s could not be created.',strDirOut);
			return;
		end
	%temporary directory so we're not left with a bunch of crap
		strDirTemp	= GetTempDir;
	%save the ev files
		cKEV	= num2cell((1:nEV)');
		cPathEV	= cellfun(@(k) PathUnsplit(strDirTemp,sprintf('ev_%d',k),'txt'),cKEV,'uni',false);
		
		if ~all(cellfun(@(f,k) fput(array2str(d(:,k)),f),cPathEV,cKEV))
			warning('not all EV files could be saved');
			return;
		end
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
					cEVOrtho{kEVO}	= StringFillTemplate(param.template('ev_orthogonalise'),sEVOrtho);
				end
				
				strEVOrtho	= join(cEVOrtho,10);
			
			kConvolve		= conditional(param.convolve(kEV),3,0);
			
			sEV			= 	struct(...
								'n'						, kEV								, ...
								'name'					, param.ev_name{kEV}				, ...
								'shape'					, 2									, ...%only implement manually-defined EVs for now
								'convolve'				, kConvolve							, ...
								'convolve_phase'		, 0									, ...%?
								'temporal_filter'		, double(param.tfilter(kEV))		, ...
								'temporal_derivative'	, double(param.tderivative(kEV))	, ...
								'ev_path'				, cPathEV{kEV}						, ...
								'ev_orthogonalise'		, strEVOrtho						  ...
								);
			cEV{kEV}	= StringFillTemplate(param.template('ev'),sEV);
		end
		
		strEV	= join(cEV,10);
	%fill the contrast template
		%fill the t contrast template
			cTContrast	= cell(nTContrast,1);
			
			%get the real contrasts
				nEVReal			= nEV + sum(param.tderivative);
				
				%assuming all have the derivative
					tContrastReal	= reshape([param.tcontrast; zeros(size(param.tcontrast))],nTContrast,[]);
				%now just keep the columns that actually do
					bKeep			= reshape([true(1,nEV); reshape(param.tderivative,1,[])],1,[]);
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
							cTContrastReal{kTE}	= StringFillTemplate(param.template('t_contrast_vector'),sContrastVector);
						end
						
						strTContrastReal	= join(cTContrastReal,10);
					%orig
						cTContrastOrig	= cell(nEV,1);
						
						for kTE=1:nEV
							sContrastVector		= struct(...
													'type'			, 'orig'					, ...
													'n_contrast'	, kT						, ...
													'n_element'		, kTE						, ...
													'value'			, param.tcontrast(kT,kTE)	  ...
													);
							cTContrastOrig{kTE}	= StringFillTemplate(param.template('t_contrast_vector'),sContrastVector);
						end
						
						strTContrastOrig	= join(cTContrastOrig,10);
				
				sTContrast		=	struct(...
										'n'							, kT						, ...
										'title'						, param.tcontrast_name{kT}	, ...
										't_contrast_vector_real'	, strTContrastReal			, ...
										't_contrast_vector_orig'	, strTContrastOrig			  ...
										);
				cTContrast{kT}	= StringFillTemplate(param.template('t_contrast'),sTContrast);
			end
			
			strTContrast	= join(cTContrast,10);
		%fill the f-test template
			%fill the f-test vector templates
				%real
					cFTestReal	= cell(nFTest*nTContrast);
					kFFE		= 1;
					for kF=1:nFTest
						for kFE=1:nTContrast
							sFTestVector		= struct(...
													'type'		, 'real'				, ...
													'n_test'	, kF					, ...
													'n_element'	, kFE					, ...
													'value'		, param.ftest(kF,kFE)	  ...
													);
							cFTestReal{kFFE}	= StringFillTemplate(param.template('f_test_vector'),sFTestVector);
							
							kFFE	= kFFE + 1;
						end
					end
					
					strFTestReal	= join(cFTestReal,10);
				%orig
					cFTestOrig	= cell(nFTest*nTContrast);
					kFFE		= 1;
					for kF=1:nFTest
						for kFE=1:nTContrast
							sFTestVector		= struct(...
													'type'		, 'orig'			, ...
													'n_test'	, kF				, ...
													'n_element'	, kFE				, ...
													'value'		, param.ftest(kF,kFE)	  ...
													);
							cFTestOrig{kFFE}	= StringFillTemplate(param.template('f_test_vector'),sFTestVector);
							
							kFFE	= kFFE + 1;
						end
					end
					
					strFTestOrig	= join(cFTestOrig,10);
			
			sFTest		= struct(...
							'f_test_vector_real'	, strFTestReal	, ...
							'f_test_vector_orig'	, strFTestOrig	  ...
							);
			strFTest	= StringFillTemplate(param.template('f_test'),sFTest);
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
						cContrastMask{end+1}	= StringFillTemplate(param.template('contrast_mask'),sContrastMask);
					end
				end
			end
			
			strContrastMask	= join(cContrastMask,10);
		
		sContrast	=	struct(...
							't_contrast'	, strTContrast		, ...
							'f_test'		, strFTest			, ...
							'contrast_mask'	, strContrastMask	  ...
							);
		strContrast	= StringFillTemplate(param.template('contrast'),sContrast);
	%fill the main template
		bHighpass	= param.highpass~=0;
		
		nEVReal	= nEV + sum(param.tderivative);
		
		sMain		= struct(...
						'functional_path'	, strPathData			, ...
						'output_dir'		, strDirTemp			, ...
						'tr'				, tr					, ...
						'volumes'			, nVol					, ...
						'delete_volumes'	, param.delete_volumes	, ...
						'bb_thresh'			, param.bb_thresh		, ...
						'noise_level'		, param.noise_level		, ...
						'noise_ar'			, param.noise_ar		, ...
						'highpass'			, double(bHighpass)		, ...
						'highpass_cutoff'	, param.highpass		, ...
						'lowpass'			, double(param.lowpass)	, ...
						'num_ev_orig'		, nEV					, ...
						'num_ev_real'		, nEVReal				, ...
						'num_tcontrast'		, nTContrast			, ...
						'num_ftest'			, nFTest				, ...
						'ev'				, strEV					, ...
						'contrast'			, strContrast			  ...
						);
		strFEATDef	= StringFillTemplate(param.template('main'),sMain);
	%save the feat definition
		strPathFEATDef	= PathUnsplit(strDirOut,sprintf('feat-stats-%s',strFileData),'fsf');
		strPathDesign	= PathUnsplit(strDirOut,'design','fsf');
		
		fput(strFEATDef,strPathFEATDef);
		fput(strFEATDef,strPathDesign);
	%run feat
		ec	= CallProcess('feat',{strPathFEATDef},'silent',param.silent);
		
		if ec
			warning('feat process failed');
			return;
		end
	%copy the data to the output directory
		strDirFEAT	= DirAppend(strDirTemp,'.feat');
		
		if ~FileCopy(strDirFEAT,strDirOut)
			strDirFEAT	= AddSlash([RemoveSlash(strDirTemp) '.feat']);
			
			if ~FileCopy(strDirFEAT,strDirOut)
				warning('could not copy temporary feat directory %s to output.',strDirFEAT);
				return;
			end
		end
	%remove the temporary directory
		[ec,out]	= CallProcess('rm',{'-r',strDirTemp},'silent',param.silent);
	
	b	= true;
%------------------------------------------------------------------------------%
