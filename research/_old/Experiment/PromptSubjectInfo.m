function sSubject = PromptSubjectInfo(varargin)
% PromptSubjectInfo
% 
% Description:	prompt for information about a subject and return it in a struct
% 
% Syntax:	sSubject = PromptSubjectInfo([q1]='default',...,[qN])
% 
% In:
%	[qK]	- the Kth question to ask.  Can be one of the following strings:
%				'default':  ask the questions marked (d) below
%				'session_code' (d):  prompt for the session code
%				'gender' (d):  is subject male/female/other
%				'handedness' (d):  is subject left/right handed
%				'eye_correction' (d):  is subject wearing glasses/contacts
%				'age' (d):  subject's age
%				'monitor_distance':  distance between subject and monitor
%				'color_blind':	is subject color blind
%			  or an up to four-element cell of the following parameters (use []
%			  to specify default values):
%				question prompt ('')
%				field name ('info')
%				cell of extra arguments to the ask function ({})
%				if response should be a number (false)
% 
% Out:
%	sSubject	- a struct of the specified subject info
% 
% Example:	sSubject = PromptSubjectInfo('default',{'What is your favorite color','color',1});
% 
% Updated: 2010-09-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the prompts
	cPrompt	= varargin;
	if numel(cPrompt)==0 || isempty(cPrompt{1})
		cPrompt{1}	= 'default';
	end
	nPrompt	= numel(cPrompt);
%initialize the return struct
	sSubject	= struct;

for kP=1:nPrompt
	switch class(cPrompt{kP})
		case 'cell'
			[strPrompt,strField,cExtra,bNumber]	= ParseArgs(cPrompt{kP},'','info',{},false);
			strTitle								= ['Enter Subject Info: ' strField];
			
			sSubject.(strField)	= ask(strPrompt,'title',strTitle,cExtra{:});
			if isempty(sSubject.(strField))
				error('Aborted by user.');
			end
			
			if bNumber
				sSubject.(strField)	= str2num(sSubject.(strField));
			end
		case 'char'
			switch lower(cPrompt{kP})
				case 'default'
					sSubject	= StructMerge(sSubject,PromptSubjectInfo('session_code','gender','handedness','eye_correction','age'));
				case 'session_code'
					strSessionDate	= lower(FormatTime(nowms,'ddmmmyy'));
					
					sSubject	= StructMerge(sSubject,PromptSubjectInfo({'Enter session code','session',{'default',strSessionDate}}));
				case 'gender'
					sSubject	= StructMerge(sSubject,PromptSubjectInfo({'Is subject male/female?','gender',{'choice',{'male','female','other'}}}));
				case 'handedness'
					sSubject	= StructMerge(sSubject,PromptSubjectInfo({'Is subject left/right handed?','handedness',{'choice',{'left','right','neither'}}}));
				case 'eye_correction'
					sSubject	= StructMerge(sSubject,PromptSubjectInfo({'Is subject wearing glasses/contacts?','eye_correction',{'choice',{'glasses','contacts','none'}}}));
				case 'age'
					sSubject	= StructMerge(sSubject,PromptSubjectInfo({'How old is the subject?','age',{},true}));
				case 'monitor_distance'
					sSubject	= StructMerge(sSubject,PromptSubjectInfo({'Distance from monitor to subject (cm.):','monitor_distance',[],true}));
				case 'color_blind'
					sSubject	= StructMerge(sSubject,PromptSubjectInfo({'Is subject color blind?','color_blind',{'choice',{'yes','no'}}}));
				otherwise
					error(['"' cPrompt{kP} '" is an unrecognized prompt type.']);
			end
		otherwise
			error(['Input #' num2str(kP) ' is invalid.']);
	end
end

if ~isfield(sSubject,'t')
	sSubject.t	= nowms;
end
