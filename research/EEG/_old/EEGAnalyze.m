function EEGAnalyze(strDirBase,strExperiment,varargin)
% EEGAnalyze
% 
% Description:	analyze an EEG experiment
% 
% Syntax:	EEGAnalyze(strDirBase,strExperiment,<options>)
% 
% In:
% 	strDirBase		- the base experiment directory
%	strExperiment	- the name of the experiment
%	<options>:  NOTE, options marked with a * can be cells of the specified
%				values to use a different value for each session.
%		erp*:					(<required>) a cell of ERP types to compute (see
%								EEGAnalyze_ProcessSession)
%		condition*:				(<required>) a cell specifying conditions (see
%								EEGAnalyze_ProcessSession)
%		derived_data*:			(<none>) a cell specifying derived data (see
%								EEGAnalyze_DerivedData)
%		t_window_base*:			(<required>) a cell of window base names (see
%								<EEGAnalyze_ProcessSession)
%		t_window_start:			(-1) the start of the ERP window relative to the
%								base window time, in seconds
%		t_window_end:			(1) the end of the ERP window relative to the
%								base window time, in seconds
%		t_baseline_start*:		(0) the start of the baseline calculation window
%								relative to the base window time, in seconds
%		t_baseline_end*:		(0) the end of the baseline calculation window
%								relative to the base window time, in seconds
%		eye_removal*:			({'sobi','threshold'}) a cell of the eye removal
%								methods to use.  see EEGRemoveEyeArtifact.
%		thresh_eye_movement*:	(80) the threshold to use for threshold eye
%								artifact removal.  see EEGRemoveEyeArtifact.
%		thresh_window*:			(100) the threshold to use for discarding
%								windows.  can be a cell of values, one for each
%								ERP type.  see EEGThreshold.
%		ymin:					(<auto>) minimum vertical axis value.  can be a
%								cell of values, one for each ERP type.
%		ymax:					(<auto>) maximum vertical axis value.  can be a 
%								cell of values, one for each ERP type.
%		figure*:				(<required>) a cell specifying the figures to
%								save (see EEGAnalyze_SaveFigures)
%		force_preprocess*:		(false) true to force preprocessing
%		reanalyze:				(true) true to force reanalysis if an analysis
%								results .mat file already exists, false to just
%								recreate group figures
%		event_bits*:			(3:10) the bits to use for reconstructing trigger
%								codes.  see EEGRead
%		nthread:				(-1) the number of threads to use (i.e. the
%								number of simultaneous calls to issue)
%		nthread_origin:			('rel') the origin option for the call to
%								MATLABPoolOpen
%		silent:					(false) true to suppress status messages
% 
% Updated: 2010-11-15
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'erp'					, []					, ...
		'condition'				, []					, ...
		'derived_data'			, []					, ...
		't_window_base'			, []					, ...
		't_window_start'		, -1					, ...
		't_window_end'			, 1						, ...
		't_baseline_start'		, 0						, ...
		't_baseline_end'		, 0						, ...
		'eye_removal'			, {'sobi','threadhold'}	, ...
		'thresh_eye_movement'	, 80					, ...
		'thresh_window'			, 100					, ...
		'ymin'					, []					, ...
		'ymax'					, []					, ...
		'figure'				, []					, ...
		'force_preprocess'		, false					, ...
		'reanalyze'				, true					, ...
		'event_bits'			, 3:10					, ...
		'nthread'				, -1					, ...
		'nthread_origin'		, 'rel'					, ...
		'silent'				, []					  ...
		);
%make sure we have cells of each of the following options
	[opt.condition,opt.figure]																					= ForceCell(opt.condition,opt.figure,'level',3);
	[opt.erp,opt.derived_data,opt.t_window_base,opt.eye_removal,opt.thresh_window,opt.ymin,opt.ymax]			= ForceCell(opt.erp,opt.derived_data,opt.t_window_base,opt.eye_removal,opt.thresh_window,opt.ymin,opt.ymax,'level',2);
	[opt.t_baseline_start,opt.t_baseline_end,opt.thresh_eye_movement,opt.force_preprocess,opt.event_bits]		= ForceCell(opt.t_baseline_start,opt.t_baseline_end,opt.thresh_eye_movement,opt.force_preprocess,opt.event_bits);

%data directory
	strExperiment	= str2filename(strExperiment);
	strDirData		= DirAppend(strDirBase,'data',strExperiment);
%output dir
	strDirOut		= DirAppend(strDirBase,'analysis',strExperiment);
	strPathResults	= PathUnsplit(strDirOut,[lower(strExperiment) '-results'],'mat');
	CreateDirPath(strDirOut);
%session files
	cPathSessionData	= FindFilesByExtension(strDirData,'bdf');
	cPathSession		= cellfun(@(x) PathAddSuffix(x,'','mat'),cPathSessionData,'UniformOutput',false);
	nSession			= numel(cPathSessionData);
%fill singletons for values that are the same across subjects
	[cPathSessionData,opt.erp,opt.condition,opt.derived_data,opt.t_window_base,opt.eye_removal,opt.thresh_window,opt.ymin,opt.ymax,opt.figure,opt.t_baseline_start,opt.t_baseline_end,opt.thresh_eye_movement,opt.force_preprocess,opt.event_bits]	= ...
		FillSingletonArrays(cPathSessionData,opt.erp,opt.condition,opt.derived_data,opt.t_window_base,opt.eye_removal,opt.thresh_window,opt.ymin,opt.ymax,opt.figure,opt.t_baseline_start,opt.t_baseline_end,opt.thresh_eye_movement,opt.force_preprocess,opt.event_bits);
%load one session to get some parameters
	if nSession==0
		error('No sessions!');
	else
		sSession	= load(cPathSession{1});
	end
%do we need to reanalyze?
	bReanalyze	= opt.reanalyze || ~FileExists(strPathResults);


if bReanalyze
	%open the MATLAB pool
		bPoolOpened	= MATLABPoolOpen(opt.nthread,'origin',opt.nthread_origin,'ntask',nSession,'silent',opt.silent);
	%analyze each session
		[dataSession,statSession,tSession]	= deal(cell(nSession,1));
		
		fSession	= @(k) EEGAnalyze_ProcessSession(cPathSessionData{k},...
							'erp'					, opt.erp{k}					, ...
							'condition'				, opt.condition{k}				, ...
							'derived_data'			, opt.derived_data{k}			, ...
							't_window_base'			, opt.t_window_base{k}			, ...
							't_window_start'		, opt.t_window_start			, ...
							't_window_end'			, opt.t_window_end				, ...
							't_baseline_start'		, opt.t_baseline_start{k}		, ...
							't_baseline_end'		, opt.t_baseline_end{k}			, ...
							'eye_removal'			, opt.eye_removal{k}			, ...
							'thresh_eye_movement'	, opt.thresh_eye_movement{k}	, ...
							'thresh_window'			, opt.thresh_window{k}			, ...
							'ymin'					, opt.ymin{k}					, ...
							'ymax'					, opt.ymax{k}					, ...
							'figure'				, opt.figure{k}					, ...
							'experiment'			, strExperiment					, ...
							'dir_out'				, strDirOut						, ...
							'force_preprocess'		, opt.force_preprocess{k}		, ...
							'silent'				, opt.silent					  ...
							);
		
		progress(nSession,'label','Analyzing session data','silent',opt.silent);
		if bPoolOpened
			%initialize the job to process each session
				oJob	= createJob;
			%create each task
				cTask	= cell(nSession,1);
				for kS=1:nSession
					cTask{kS}	= createTask(oJob,fSession,3,{kS});
				end
			%submit the job and track its progress
				submit(oJob);
					
				k=0;
				while ~isequal(get(oJob,'State'),'finished')
					k=k+1;
					
					tStart	= nowms;
					
					%number of finished tasks
						nFinished	= sum(cellfun(@(x) ~ismember(get(x,'State'),{'pending','running'}),cTask));
					
					if nFinished~=nSession
						progress(nFinished);
					end
					
					pause(0.01);
				end
				
				%parse the outputs
					cOut	= getAllOutputArguments(oJob);
					
					dataSession(:)	= cOut(:,1);
					statSession(:)	= cOut(:,2);
					tSession(:)		= cOut(:,3);
					
				progress('end');
			%destroy the job
				destroy(oJob);
		else
			for kS=1:nSession
				[dataSession{kS},statSession{kS},tSession{kS}]	= fSession(kS);
				
				progress;
			end
		end
	%close the pool
		bPoolClosed	= MATLABPoolClose('silent',opt.silent);
	%get the time vector
		cField	= fieldnames(tSession{1});
		tWindow	= tSession{1}.(cField{1});
	%process the group data
		[dataGroup,statGroup]	= EEGAnalyze_ProcessGroup(tWindow,dataSession,sSession,strDirOut,opt.figure{1},'experiment',strExperiment,'ymin',opt.ymin{1},'ymax',opt.ymax{1},'silent',opt.silent);
	%save the group and individual results
		status('saving results','silent',opt.silent);
		
		%remove the windows (too much!)
			dataSession	= cellfun(@(x) rmfield(x,'win'),dataSession,'UniformOutput',false);
			dataGroup	= rmfield(dataGroup,'win');
		
		save(strPathResults,'tWindow','dataSession','dataGroup','statSession','statGroup');
else
	statGroup	= load(strPathResults,'statGroup','tWindow');
	tWindow		= statGroup.tWindow;
	statGroup	= statGroup.statGroup;
	
	%process the group data
		[dataGroup,statGroup]	= EEGAnalyze_ProcessGroup(tWindow,[],sSession,strDirOut,opt.figure{1},'experiment',strExperiment,'ymin',opt.ymin{1},'ymax',opt.ymax{1},'stat',statGroup,'silent',opt.silent);
end
