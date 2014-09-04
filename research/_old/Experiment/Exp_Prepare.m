function sSession = Exp_Prepare(strType,varargin)
% Exp_Prepare
% 
% Description:	prepare an experiment session
% 
% Syntax:	sSession = Exp_Prepare(strType,<options>)
% 
% In:
% 	strType	- the type of experiment to prepare.  can be:
%					'eeg':	an EEG experiment
%	<options>:
%		name:			('experiment') the experiment name
%		dir_base:		(<see note>) base experiment directory.  defaults first
%						to the global variable strDirBase.  if this is empty
%						then defaults to pwd
%		param:			(struct) a struct of parameters used in the experiment
%		screen_dim:		(<see PTBNewWindow>) the screen dimensions
%		fixation:		(true) the fixation parameter (see PTBNewWindow)
%		key:			(<none>) an Nx7 cell array specifying the key
%						combinations that will be used.  Each row formatted as:
%							name,keys,neutral,bad,triggergood,triggerbad,reset
%						use trigger names rather than values.  see
%						PTBKeyCheckRegister for documentation.  Use [] where
%						defaults are desired.
%		subject_prompt:	(<none>) a cell of extra subject prompts (see
%						PromptSubjectInfo)
%		debug:			(false) true if this is a debug run of the experiment
%		windowed:		(false) true to run the experiment in a windowed screen
%
%		if strType=='eeg':
%			trigger:		(true) true to use triggers
%			triggercode:	(<none>) a cell of trigger names to add to the
%							trigger code set
% 
% Out:
% 	sSession	- the session struct
% 
% Updated: 2010-10-29
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'name'				, 'experiment'	, ...
		'dir_base'			, []			, ...
		'param'				, struct		, ...
		'screen_dim'		, []			, ...
		'fixation'			, true			, ...
		'key'				, {}			, ...
		'subject_prompt'	, {}			, ...
		'debug'				, false			, ...
		'windowed'			, false			, ...
		'trigger'			, true			, ...
		'triggercode'		, {}			  ...
		);
if isempty(opt.dir_base)
	bUseGlobal	= false;
	
	gVars	= whos('global');	%check for global strDirBase
	if ismember('strDirBase',{gVars.name})
		global strDirBase;
		bUseGlobal	=  ~isempty(strDirBase);
	end
	
	opt.dir_base	= conditional(bUseGlobal,strDirBase,pwd);
end

sSession.type	= strType;
bEEG			= isequal(sSession.type,'eeg');

sSession.debug	= opt.debug;

sSession.param							= opt.param;
sSession.param.experiment_name			= opt.name;
sSession.param.experiment_name_safe	= str2fieldname(sSession.param.experiment_name);
sSession.param.screen_dim				= opt.screen_dim;
sSession.param.fixation					= opt.fixation;

%initialize some time arrays
	sSession.t	= dealstruct('trialStart','trialEnd','tutorialTrialStart','tutorialTrialEnd',[]);
%clear the MATLAB console window
	if ~sSession.debug
		clc;
	end
%start the log
	if ~sSession.debug
		sSession.param.path_log	= GetTempFile;
		diary(sSession.param.path_log);
		
		status(['Log started for experiment "' sSession.param.experiment_name '"']);
	end
%prepare the trigger mechanism
	if bEEG
		%trigger codes
			cTriggerCode	=	[{
									'session_start'
									'session_end'
									'tutorial_start'
									'tutorial_end'
									'experiment_start'
									'experiment_end'
									'trial_start'
									'trial_end'
								}
									reshape(opt.triggercode,[],1)
								];
			nTriggerCode			= numel(cTriggerCode);
			sSession.triggercode	= cell2struct(num2cell(reshape(1:nTriggerCode,[],1)),cTriggerCode);
		%prepare the trigger struct
			if opt.trigger
				sSession.trigger	= TriggerPrepare('bit',17:24,'bitorder','msb','debug',sSession.debug);
			else
				sSession.trigger	= [];
			end
	end
%base keyboard state
	if ~isempty(opt.key)
		sSession	= PTBKeyStateBase(sSession);
	end
%output directory
	sSession.param.dir_base	= opt.dir_base;
	sSession.param.dir_data	= DirAppend(sSession.param.dir_base,'data',sSession.param.experiment_name_safe);
	CreateDirPath(sSession.param.dir_data);
%calculate GetSecs time
	n			= status('calculating internal GetSecs time');
	sSession	= PTBGetSecsTime(sSession);
	
	status(['internal GetSecs time: ' num2str(sSession.ptb.getsecstime)],'noffset',n+1); 
%keys
	nKey	= size(opt.key,1);
	for kK=1:nKey
		sSession	= PTBKeyCheckRegister(sSession																, ...
											opt.key{kK,1}														, ...
											opt.key{kK,2}														, ...
											'neutral',opt.key{kK,3}												, ...
											'bad',opt.key{kK,4	}												, ...
											'triggergood',GetFieldPath(sSession,'triggercode',opt.key{kK,5})	, ...
											'triggerbad',GetFieldPath(sSession,'triggercode',opt.key{kK,6})	, ...
											'rest',opt.key{kK,7}												  ...
										);
	end
%prompt for subject data
	if ~sSession.debug
		sSession.subject			= PromptSubjectInfo([],opt.subject_prompt{:});
		sSession.param.path_data	= PathUnsplit(sSession.param.dir_data,sSession.subject.session,'mat');
		
		if exist(sSession.param.path_data) && ~isequal(ask(['Subject ' sSession.subject.session ' already exists.  Continue?'],sSession.param.experiment_name,'Yes','No','No'),'Yes')
			error('Experiment aborted');
		end
	end
%prompt to prepare EEG subject
	if ~sSession.debug && bEEG
		EEGChannel2IndexDisplay;
		uiwait(msgbox('Prepare subject now.',sSession.param.experiment_name,'modal'));
		uiwait(msgbox('Move the EEG window!.',sSession.param.experiment_name,'modal'));
	end
%open the stimulus window
	sSession.t.stimulusOpen	= GetSecs;
	status('opening stimulus window');
	
	sSession	= PTBNewWindow(sSession,'windowed',opt.windowed,'windowdim',sSession.param.screen_dim,'fixation',sSession.param.fixation);
%prompt to begin EEG recording
	if ~sSession.debug && bEEG
		uiwait(msgbox('Start EEG recording now.',sSession.param.experiment_name,'modal'));
		WaitSecs(1);
	end
%disable MATLAB keyboard input
	if ~sSession.debug
		status('MATLAB keyboard input disabled');
		ListenChar(2);
	end
%start of the session
	status('session started');
	
	sSession.t.startGetSecs	= GetSecs;
	sSession.t.startMS		= nowms;
	
	if bEEG
		[sSession.trigger,sSession.t.sessionStart]	= TriggerSet(sSession.trigger,sSession.triggercode.session_start);
	else
		sSession.t.sessionStart	= GetSecs;
	end
