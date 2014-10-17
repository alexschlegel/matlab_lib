classdef Experiment < PTB.Object
% PTB.Experiment
% 
% Description:	an object to extend and simplify use of Psychtoolbox
% 
% Syntax:	ptb = PTB.Experiment(<options>)
% 			
%			subfunctions:
%				Start(<options>):	start the object
%				End:				end the object
%				Abort:				abort the experiment
%				Attach:				attach a PTB.Object to the experiment
%
% 			subclasses:
% 				Info:		stores info accessible to all PTB classes
%				File:		read/write files
%				Subject:	get and prompt for subject info
%				Scheduler:	schedule execution of tasks with different
%							priorities
%				Color:		store/parse colors
%				Status:		show status messages
%				Prompt:		prompt for information
%				Log:		log events
%				Serial:		access a serial port
%				[Trigger]:	set and send EEG triggers
%				Input:		check subject input
%				Scanner:	query and simulate the scanner
%				Window:		manipulate the stimulus window
%				Pointer:	get the state of a pointer device
%				Show:		paint stimuli on the window
%				Sequence:	do a sequence of things
%				[Draw]:		handle drawing functions
% 
% In:
% 	<options>:
%		name:			('Experiment') the name of the experiment
%		debug:			(0) a value specifying the type of debugging:
%							0:	none
%							1:	test run
%							2:	development
%		disable_key		(<true if debug==0>) true to disable the keyboard
%		disable_mouse:	(<true if debug==0>) true to hide the mouse
%		context:		('psychophysics') the experiment context.  one of the
%						following:
%							fmri:			experiment shown in the scanner
%							eeg:			EEG experiment
%							psychophysics:	psychophysics experiment
%		input:			(<auto>) the input type.  one of 'buttonbox',
%						'joystick', 'keyboard', or 'autobahx'.  defaults to
%						'keyboard' if debug==2 and context~=fmri.  otherwise,
%						defaults:
%							fmri:			buttonbox
%							eeg:			joystick
%							psychophysics:	joystick
%		pointer:		('none') the pointer type.  one of 'none', 'mouse',
%						'wacom', or 'magictouch'
%		usetrigger:		(<true if eeg>) true to include the Trigger object
%		usedraw:		(<true if pointer is wacom or magictouch>) true to
%						Include the Draw object
%		autosave:		(<10000 unless debug==2>) the autosave interval, in
%						milliseconds.  the experiment will automatically save
%						the info struct at this interval while idle.  set to
%						false to skip autosaving.
%		start:			(true) true to autostart
%		<see subclasses for more available options>
% 
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		Info;
		File;
		Subject;
		Scheduler;
		Color;
		Status;
		Prompt;
		Log;
		Serial;
		Trigger;
		Input;
		Scanner;
		Window;
		Pointer;
		Show;
		Sequence;
		Draw;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		argin	= {};
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function ptb = Experiment(varargin)
			ptb			= ptb@PTB.Object([],'experiment');
			ptb.parent	= ptb;
			
			ptb.argin	= varargin;
			
			%initialize some subclasses
				ptb.Info	= PTB.Info(ptb);
				
				ptb.File		= PTB.File(ptb);
				ptb.Subject		= PTB.Subject(ptb);
				ptb.Scheduler	= PTB.Scheduler(ptb);
				ptb.Color		= PTB.Color(ptb);
				ptb.Status		= PTB.Status(ptb);
				ptb.Prompt		= PTB.Prompt(ptb);
				ptb.Log			= PTB.Log(ptb);
			%start the info object
				ptb.Info.Start(varargin{:});
			
			%parse the inputs
				opt	= ParseArgs(varargin,...
						'debug'			, 0					, ...
						'context'		, 'psychophysics'	, ...
						'input'			, []				, ...
						'pointer'		, 'none'			, ...
						'usetrigger'	, []				, ...
						'usedraw'		, []				, ...
						'start'			, true				  ...
						);
				
				%context
					opt.context	= CheckInput(opt.context,'context',{'fmri','eeg','psychophysics'});
					ptb.Info.Set('experiment','context',opt.context,'replace',false);
					opt.context	= ptb.Info.Get('experiment','context');
				%input
					if isempty(opt.input)
						if opt.debug>1 && ~isequal(opt.context,'fmri')
							opt.input	= 'keyboard';
						else
							opt.input	= switch2(opt.context,...
											'fmri'			, 'buttonbox'	, ...
											'eeg'			, 'joystick'	, ...
											'psychophysics'	, 'joystick'	  ...
											);
						end
					end
					
					opt.input	= CheckInput(opt.input,'input',{'buttonbox','joystick','keyboard','autobahx'});
					ptb.Info.Set('experiment','input',opt.input,'replace',false);
					opt.input	= ptb.Info.Get('experiment','input');
				%pointer
					opt.pointer	= CheckInput(opt.pointer,'pointer',{'none','mouse','wacom','magictouch'});
					ptb.Info.Set('experiment','pointer',opt.pointer,'replace',false);
					opt.pointer	= ptb.Info.Get('experiment','pointer');
				
				opt.usetrigger	= unless(opt.usetrigger,isequal(lower(opt.context),'eeg'));
				opt.usedraw		= unless(opt.usedraw,ismember(lower(opt.pointer),{'wacom','magictouch'}));
			
			%initialize the rest of the subclasses
				ptb.Serial	= PTB.Device.Serial(ptb);
				
				%input
					switch opt.input
						case 'buttonbox'
							ptb.Input	= PTB.Device.Input.ButtonBox(ptb);
						case 'joystick'
							ptb.Input	= PTB.Device.Input.Joystick(ptb);
						case 'keyboard'
							ptb.Input	= PTB.Device.Input.Keyboard(ptb);
						case 'autobahx'
							ptb.Input	= PTB.Device.Input.AutoBahx(ptb);
					end
				%pointer
					switch opt.pointer
						case 'none'
							ptb.Pointer	= PTB.Device.Pointer(ptb,'no_pointer');
						case 'mouse'
							ptb.Pointer	= PTB.Device.Pointer.Mouse(ptb);
						case 'wacom'
							ptb.Pointer	= PTB.Device.Pointer.Wacom(ptb);
						case 'magictouch'
							ptb.Pointer	= PTB.Device.Pointer.MagicTouch(ptb);
					end
				
				ptb.Scanner		= PTB.Device.Scanner(ptb);
				ptb.Window		= PTB.Window(ptb);
				ptb.Show		= PTB.Show(ptb);
				ptb.Sequence	= PTB.Sequence(ptb);
                
				%optional subclasses
					%trigger
						ptb.Info.Set('experiment',{'use','trigger'},opt.usetrigger,'replace',false);
						
						if ptb.Info.Get('experiment',{'use','trigger'})
							ptb.Trigger	= PTB.Device.Trigger(ptb);
						end
					%draw
						ptb.Info.Set('experiment',{'use','draw'},opt.usedraw,'replace',false);
						
						if ptb.Info.Get('experiment',{'use','draw'})
							ptb.Draw	= PTB.Draw(ptb);
						end
					
			if opt.start
				ptb.Start;
			end
		end
		%----------------------------------------------------------------------%
		function Start(ptb,varargin)
		%start the session
			tNow	= PTB.Now;
			
			ptb.argin	= append(ptb.argin,varargin);
			v			= ptb.argin;
			
			%parse the options
				opt	= ParseArgs(v,...
						'name'			, 'Experiment'		, ...
						'debug'			, 0					, ...
						'disable_key'	, []				, ...
						'disable_mouse'	, []				, ...
						'autosave'		, []				  ...
						);
				opt.autosave		= unless(opt.autosave,conditional(opt.debug==2,false,10000));
			%set some info
				ptb.Info.Set('experiment','name',opt.name,'replace',false);
				ptb.Info.Set('experiment','start',tNow,'replace',false);
				ptb.Info.Set('experiment','autosave',opt.autosave,'replace',false);
				ptb.Info.Set('experiment','debug',opt.debug);
				
			%start the other objects
				ptb.File.Start(v{:});
				ptb.Subject.Start(v{:});
				ptb.Scheduler.Start(v{:});
				ptb.Color.Start(v{:});
				ptb.Status.Start(v{:});
				ptb.Prompt.Start(v{:});
				ptb.Log.Start(v{:});
				ptb.Serial.Start(v{:});
				
				if ptb.Info.Get('experiment',{'use','trigger'})
					ptb.Trigger.Start(v{:});
				end
				
				ptb.Input.Start(v{:});
				ptb.Scanner.Start(v{:});
				ptb.Window.Start(v{:});
				ptb.Pointer.Start(v{:});
				ptb.Show.Start(v{:});
				ptb.Sequence.Start(v{:});
				
				if ptb.Info.Get('experiment',{'use','draw'})                
					ptb.Draw.Start(v{:});
				end
			%attach the dynamic objects
				ptb.Attach(ptb.Info.Get('experiment','object'));
			
			%start the autosave
				ptb.Info.AutoSave(ptb.Info.Get('experiment','autosave'));
			
			%disable the mouse and keyboard
				opt.disable_key		= unless(opt.disable_key,opt.debug==0);
				opt.disable_mouse	= unless(opt.disable_mouse,opt.debug==0);
				
				ptb.Info.Set('experiment',{'disable','key'},opt.disable_key);
				ptb.Info.Set('experiment',{'disable','mouse'},opt.disable_mouse);
				
				if opt.disable_mouse
					HideCursor;
				end
				
				if opt.disable_key
					ListenChar(2);
				end
		end
		%----------------------------------------------------------------------%
		function End(ptb,varargin)
		%end the session
			v	= varargin;
			
			%enable the mouse and keyboard
				if ptb.Info.Get('experiment',{'disable','mouse'})
					ShowCursor;
				end
				
				if ptb.Info.Get('experiment',{'disable','key'})
					ListenChar(1);
				end
			
			%end the attached objects
				sObj	= ptb.Info.Get('experiment','object');
				
				if ~isempty(sObj) && ~isequal(sObj,struct)
					cField	= fieldnames(sObj);
					nField	= numel(cField);
					
					for kF=1:nField
						ptb.(cField{kF}).End(v{:});
					end
				end
			
			%end each subclass
				if ptb.Info.Get('experiment',{'use','draw'})
					ptb.Draw.End(v{:});
				end
				
				ptb.Sequence.End(v{:});
				ptb.Show.End(v{:});
				ptb.Pointer.End(v{:});
				ptb.Window.End(v{:});
				ptb.Scanner.End(v{:});
				ptb.Input.End(v{:});
				
				if ptb.Info.Get('experiment',{'use','trigger'})
					ptb.Trigger.End(v{:});
				end
				
				ptb.Serial.End(v{:});
				ptb.Log.End(v{:});
				ptb.Prompt.End(v{:});
				ptb.Status.End(v{:});
				ptb.Color.End(v{:});
				ptb.Scheduler.End(v{:});
				ptb.Subject.End(v{:});
				ptb.File.End(v{:});
				ptb.Info.End(v{:});                
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
