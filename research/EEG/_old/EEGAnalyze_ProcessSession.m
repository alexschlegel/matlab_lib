function [dat,stat,t] = EEGAnalyze_ProcessSession(strPathData,varargin)
% EEGAnalyze_ProcessSession
% 
% Description:	analyze a single EEG session
% 
% Syntax:	[dat,stat,t] = EEGAnalyze_ProcessSession(strPathData,<options>)
% 
% In:
% 	strPathData	- the path to the raw EEG data file
%	<options>:
%		erp:					(<required>) a cell of ERP types to compute.  can
%								include any of the following:
%									rp:		the ERP at Cz
%									lrp:	the average of C3-C4 for lefthand
%											trials and C4-C3 for righthand trials
%									emg:	the average of left EMG for righthand
%											trials and right EMG for righthand
%											trials
%		condition:				(<required>) an N-length cell of M(k)x3 cells
%								specifying the M(k) states of each of N
%								conditions used in the experiment.  the first
%								column of each M(k)x3 cell specifies the names
%								of each state of the specified condition.  the
%								second column specifies a function used to
%								determine the value of the state for each trial,
%								or a string that evaluates to such a function.
%								if this function will be called via a MATLAB
%								parallel processing job then use the string form,
%					  			since function handles apparently don't carry
%								over to the labs that process the function.  the
%								third column is a cell of field names of the
%								struct sSession.trial, specifying the inputs to
%								the function.  For example, if the first
%								condition cell classifies the hand used in the
%								trial, then the cell might look like this:
%									{	'left'	@(x) x==1	{'kHand'}
%										'right'	@(x) x==2	{'kHand'}	}
%								each specified field of sSession.trial should be
%								a vector with one entry for each trial.  NOTE:
%								if RP, LRP, EMG ERPs are specified, then the
%								last condition type must be the hand used for
%								the trial.
%		derived_data:			(<none>) a cell specifying derived data (see
%								EEGAnalyze_DerivedData)
%		t_window_base:			(<required>) a cell of names of time vectors
%								stored in sSession.trial.  if
%								sSession.trial.tPrompt is the desired field, then
%								'prompt' should be included in t_window_base
%		t_window_start:			(-1) the start of the ERP window relative to the
%								base window time, in seconds
%		t_window_end:			(1) the end of the ERP window relative to the
%								base window time, in seconds
%		t_baseline_start:		(0) the start of the baseline calculation window
%								relative to the base window time, in seconds
%		t_baseline_end:			(0) the end of the baseline calculation window
%								relative to the base window time, in seconds
%		eye_removal:			({'sobi','threshold'}) a cell of the eye removal
%								methods to use.  see EEGRemoveEyeArtifact.
%		thresh_eye_movement:	(80) the threshold to use for threshold eye
%								artifact removal.  see EEGRemoveEyeArtifact.
%		thresh_window:			(100) the threshold to use for discarding
%								windows.  can be a cell of values, one for each
%								ERP type.  see EEGThreshold.
%		ymin:					(<auto>) minimum vertical axis value.  can be a
%								cell of values, one for each ERP type.
%		ymax:					(<auto>) maximum vertical axis value.  can be a 
%								cell of values, one for each ERP type.
%		figure:					(<required>) a cell specifying the figures to
%								save (see EEGAnalyze_SaveFigures)
%		experiment:				('') the name of the experiment
%		dir_out:				(<same as input>) the directory to which to save
%								figures
%		force_preprocess:		(false) true to force preprocessing
%		event_bits:				(3:10) the bits to use for reconstructing trigger
%								codes.  see EEGRead
%		silent:					(false) true to suppress status messages
% 
% Out:
% 	dat		- a struct of data
%	stat	- a struct of statistical results
%	t		- a struct of time vectors
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
		'eye_removal'			, {'sobi','threshold'}	, ...
		'thresh_eye_movement'	, 80					, ...
		'thresh_window'			, 100					, ...
		'ymin'					, []					, ...
		'ymax'					, []					, ...
		'figure'				, []					, ...
		'experiment'			, ''					, ...
		'dir_out'				, []					, ...
		'force_preprocess'		, false					, ...
		'event_bits'			, 3:10					, ...
		'silent'				, false					  ...
		);
if isempty(opt.dir_out)
	opt.dir_out	= PathGetDir(strPathData);
end
if ~isequal(opt.thresh_window,false)
	[opt.erp,opt.thresh_window]	= FillSingletonArrays(opt.erp,opt.thresh_window);
end

%load the session info
	strPathSession	= PathAddSuffix(strPathData,'','mat');
	strSession		= PathGetFilePre(strPathData);
	sSession		= load(strPathSession);

status(['Analyzing session ' strSession],'silent',opt.silent);

%get the eye removal methods to use
	bEyeSOBI		= ismember('sobi',opt.eye_removal);
	bEyeThreshold	= ismember('threshold',opt.eye_removal);
%get the relevant channels
	[cChannel,cChannelNoEye]	= GetChannels;
%preprocess the data
	hdr	= EEGPreprocess(strPathData,cChannel,'event_bits',opt.event_bits,'crop_start_event',sSession.triggercode.experiment_start,'crop_end_event',sSession.triggercode.experiment_end,'force',opt.force_preprocess);
	fs	= hdr.channel.data(1).rate;
%get the reference times in Psychtoolbox and EEG space
	[tPTB,tEEG]	= GetTimes;
%load the windows
	[eeg,t]	= ProcessWindows;
%classify trials by conditions
	dat	= ClassifyTrials;
%sort the windows
	dat.win	= SortWindows;
%get the time vector
	cField	= fieldnames(t);
	tWindow	= t.(cField{1});

%calculate stats and save windows
	[dat,stat]	= EEGAnalyze_ProcessDataSet(tWindow,dat,sSession,opt.experiment,strSession,opt.dir_out,opt.derived_data,opt.figure,'ymin',opt.ymin,'ymax',opt.ymax,'silent',opt.silent);


%------------------------------------------------------------------------------%
function [c,cNoEye] = GetChannels()
% get the channels that need to be processed
	c	= reshape(opt.erp,[],1);
	if bEyeSOBI
		c	= [c; {'head'; 'eog'}];
	end
	if bEyeThreshold
		c	= [c; {'eyemovement'}];
	end
	
	cNoEye	= setdiff(c,{'head';'eog'});
end
%------------------------------------------------------------------------------%
function [tPTB,tEEG] = GetTimes()
%get PTB and EEG times from sSession.trial, formatted as sSession.trial.t<Name>
	%references times in each space
		tPTBExperimentStart	= sSession.t.experimentStart;
		tPTBExperimentEnd	= sSession.t.experimentEnd;
		tEEGExperimentStart	= k2t(hdr.event.start(hdr.event.type==sSession.triggercode.experiment_start),fs);
		tEEGExperimentEnd	= k2t(hdr.event.start(hdr.event.type==sSession.triggercode.experiment_end),fs);
	%PTB times
		nTime	= numel(opt.t_window_base);
		
		tPTB	= struct;
		for kT=1:nTime
			strFieldPTB						= ['t' upper(opt.t_window_base{kT}(1)) opt.t_window_base{kT}(2:end)];
			tPTB.(opt.t_window_base{kT})	= sSession.trial.(strFieldPTB);
		end
	%EEG times
		tEEG	= structfun2(@(x) TimeAlign(x,tPTBExperimentStart,tPTBExperimentEnd,tEEGExperimentStart,tEEGExperimentEnd),tPTB);
end
%------------------------------------------------------------------------------%
function [eeg,t] = ProcessWindows()
% load, baseline, eye removal for each set of windows specified
	status('processing EEG windows');
	
	[sChannel,kChannel]	= EEGChannel(cChannel,hdr,'readstatus',false);
	
	[eeg,t]	= structfun2(@(x) EEGRead(hdr.path_data,'channel',kChannel.read,'twinbase',x,'twinstart',opt.t_window_start,'twinend',opt.t_window_end),tEEG);
	eeg		= structfun2(@(x,y) EEGChangeFromBaseline(x,'t',y,'start',opt.t_baseline_start,'end',opt.t_baseline_end),eeg,t);
	if bEyeSOBI
		eeg	= structfun2(@(x) EEGRemoveEyeArtifact(x,'output',cChannelNoEye),eeg);
	end
end
%------------------------------------------------------------------------------%
function dat = ClassifyTrials()
% classify trials by errors and conditions
	%trials with no subject error
		dat.b.NoError	= dealstruct(opt.erp{:},dealstruct(opt.t_window_base{:},reshape(~sSession.trial.bError,[],1)));
	%non-NaN trials
		dat.b.NoNaN	= dealstruct(opt.erp{:},structfun2(@(x) ~isnan(x),tPTB));
	%flag trials with H&E's definition of eye movement
		if bEyeThreshold
			[eeg,bEyes]		= structfun2(@(x) EEGRemoveEyeArtifact(x,'method','threshold','threshold',opt.thresh_eye_movement,'remove',false,'silent',true),eeg);
			bNoEyes			= structtreefun(@(x) ~x,bEyes);
			dat.b.NoEyes	= dealstruct(opt.erp{:},bNoEyes);
		end
	%flag trials that exceed a threshold
		if notfalse(opt.thresh_window)
			nERP	= numel(opt.erp);
			for kE=1:nERP
				strERP	= opt.erp{kE};
				
				[eeg,bAboveThreshold]			= structfun2(@(x) EEGThreshold(x,'threshold',opt.thresh_window{kE},'channel',strERP,'remove',false,'silent',true),eeg);
				dat.b.BelowThreshold.(strERP)	= structtreefun(@(x) ~x,bAboveThreshold);
			end
		end
	%valid trials
		cB			= struct2cell(dat.b);
		dat.b.Valid	= structtreefun(@(varargin) all(cat(2,varargin{:}),2),cB{:});
	%classify each trial
		nCondition	= numel(opt.condition);
		cCondition	= repmat({struct},[nCondition 1]);
		
		for kC=1:nCondition
			nState	= size(opt.condition{kC},1);
			
			for kS=1:nState
				strNameState	= opt.condition{kC}{kS,1};
				
				f				= opt.condition{kC}{kS,2};
				if ischar(f)
					f	= str2func(f);
				end
				
				cInput			= cellfun(@(x) sSession.trial.(x),ForceCell(opt.condition{kC}{kS,3}),'UniformOutput',false);
				
				bInState		= f(cInput{:});
				
				cCondition{kC}	= StructMerge(cCondition{kC},structtreefun(@(x) struct(strNameState,x & bInState),dat.b.Valid));
			end
		end
		
		dat.b.Tree	= ClassifierTree(cCondition{:});
end
%------------------------------------------------------------------------------%
function win = SortWindows()
	status('sorting windows by condition','silent',opt.silent);
	
	[sChannel,kFileRaw,kChannel]	= EEGChannel(cChannelNoEye,eeg.(opt.t_window_base{1}).hdr);
	
	nERP	= numel(opt.erp);
	for kE=1:nERP
		switch opt.erp{kE}
			case 'rp'
				win.rp	= structfun2(@(t,e) structtreefun(@(x) GetWin(e,kChannel.rp,x.any),t,'offset',1),dat.b.Tree.rp,eeg);
			case 'lrp'
				win.lrp	= structfun2(@(t,e) structtreefun(@(x) [GetWin(e,kChannel.lrp_l,x.left)-GetWin(e,kChannel.lrp_r,x.left);GetWin(e,kChannel.lrp_r,x.right)-GetWin(e,kChannel.lrp_l,x.right)],t,'offset',1),dat.b.Tree.lrp,eeg);
			case 'emg'
				win.emg	= structfun2(@(t,e) structtreefun(@(x) [GetWin(e,kChannel.emg_l,x.left); GetWin(e,kChannel.emg_r,x.right)],t,'offset',1),dat.b.Tree.emg,eeg);
			otherwise
				error(['"' opt.erp{kE} '" is not a recognized ERP type.']);
		end
	end
end
%------------------------------------------------------------------------------%
function w = GetWin(eeg,k,b)
%get the windows specified by logical b from eeg.data(k,:,:)
	w	= permute(mean(eeg.data(k,b,:),1),[2 3 1]);
end
%------------------------------------------------------------------------------%

end
