classdef PsychMic < Alexizer.Input.Base
% Alexizer.Input.PsychMic
% 
% Description:	Psychtoolbox microphone input
% 
% Syntax:	inp = Alexizer.Input.PsychMic
% 
% 			subfunctions:
% 				Open:	open the input device
%				Close:	close the input device 
%				Start:	start recording
%				Stop:	stop recording
%				Read:	read the next sample block
% 
% 			properties:
%				rate:		(44100) sample rate, in Hz
% 				duration:	(125) sample block duration, in ms
% 
% Updated: 2012-06-10
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	properties (SetAccess=protected)
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		h	= 0;
	end
	properties (SetAccess=protected, GetAccess=protected, Constant)
		PSYCH_MODE_CAPTURE				= 2;
		PSYCH_LATENCY_MOSTAGGRESSIVE	= 3;
		
		nChannels	= 1;
		durBuffer	= 10;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function inp = PsychMic()
			inp	= inp@Alexizer.Input.Base;
		end
		%-----------------------------------------------------------------------%
		function b = Open(inp,varargin)
		% b = inp.Open(rate,duration)
			if Open@Alexizer.Input.Base(inp,varargin{:})
				try
					InitializePsychSound;
					
					inp.h	= PsychPortAudio('Open', [], inp.PSYCH_MODE_CAPTURE, inp.PSYCH_LATENCY_MOSTAGGRESSIVE, inp.rate, inp.nChannels);
					
					PsychPortAudio('GetAudioData', inp.h, inp.durBuffer);
					
					b	= true;
				catch
					inp.opened	= false;
					b			= false;
				end
			else
				b	= false;
			end
		end
		%-----------------------------------------------------------------------%
		function b = Close(inp)
		% b = inp.Close
			b	= Close@Alexizer.Input.Base(inp);
			
			if b
				PsychPortAudio('Close',inp.h);
			end
		end
		%-----------------------------------------------------------------------%
		function b = Start(inp)
		% b = inp.Start
			b	= Start@Alexizer.Input.Base(inp);
			
			if b
				inp.tStart	= PsychPortAudio('Start',inp.h, 0, 0, 1);
			end
		end
		%-----------------------------------------------------------------------%
		function b = Stop(inp)
		% b = inp.Stop
			b	= Stop@Alexizer.Input.Base(inp);
			
			if b
				PsychPortAudio('Stop', inp.h);
			end
		end
		%-----------------------------------------------------------------------%
		function [t,x] = Read(inp)
		% [t,x] = inp.Read
			if inp.started
				x	= PsychPortAudio('GetAudioData',inp.h,[],inp.duration,[]);
				
				x	= x';
				t	= inp.Now - inp.tStart + k2t(1-size(x,1):0,inp.rate)';
			else
				t	= [];
				x	= [];
			end
		end
		%-----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=protected)
		%-----------------------------------------------------------------------%
		function t = Now(inp)
			t	= GetSecs;
		end
		%-----------------------------------------------------------------------%
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
