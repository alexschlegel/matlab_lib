function sSession = Exp_Conclude(sSession)
% Exp_Conclude
% 
% Description:	conclude an experiment session
% 
% Syntax:	sSession = Exp_Conclude(sSession)
% 
% Updated: 2010-10-29
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bEEG	= isequal(sSession.type,'eeg');

%set the session end trigger
	status('session ended');
	
	if bEEG
		[sSession.trigger,sSession.t.sessionEnd]	= TriggerSet(sSession.trigger,sSession.triggercode.session_end);
	end

	sSession.t.endGetSecs	= GetSecs;
	sSession.t.endMS		= nowms;
%enable MATLAB keyboard input
	if ~sSession.debug
		WaitSecs(0.5);
		
		status('MATLAB keyboard input enabled');
		ListenChar(0);
	end
%show the experiment ended screen
	sSession	= PTBInstructions(sSession,'Experiment Finished.','prompt',' ','fend','nowait');
%prompt to end EEG recording
	if ~sSession.debug && bEEG
		uiwait(msgbox('Stop EEG recording now.',sSession.param.experiment_name,'modal'));
	end
%close the stimulus window
	sSession.t.stimulusClose	= GetSecs;
	status('closing stimulus window');
	
	Screen('Close',sSession.ptb.h);
%close the log
	if ~sSession.debug
		status(['Log closed for experiment "' sSession.param.experiment_name '".  Writing data...']);
	end
%save the data one last time
	sSession	= Exp_SaveData(sSession);
%end the diary
	if ~sSession.debug
		diary off
		delete(sSession.param.path_log);
	end
