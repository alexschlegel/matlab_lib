classdef Base < Alexizer.Object
% Alexizer.Input.Base
% 
% Description:	base input device object
% 
% Syntax:	inp = Alexizer.Input.Base
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
% 				duration:	(0.125) sample block duration, in s
% 
% Updated: 2012-06-10
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		rate		= 44100;
		duration	= 0.125;
	end
	properties (SetAccess=protected)
		opened	= false;
		started	= false;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		tStart	= 0;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function inp = Base()
			inp	= inp@Alexizer.Object;
		end
		%-----------------------------------------------------------------------%
		function b = Open(inp,varargin)
		% b = inp.Open([rate],[duration])
			if ~inp.opened || inp.Close
				[inp.rate,inp.duration]	= ParseArgs(varargin,inp.rate,inp.duration);
				
				inp.opened	= true;
				b			= true;
			else
				b	= false;
			end
		end
		%-----------------------------------------------------------------------%
		function b = Close(inp)
		% b = inp.Close
			if inp.opened && (~inp.started || inp.Stop)
				inp.opened	= false;
				b			= true;
			else
				b	= false;
			end
		end
		%-----------------------------------------------------------------------%
		function b = Start(inp)
		% b = inp.Start
			if inp.opened && (~inp.started || inp.Stop)
				inp.tStart	= inp.Now;
				
				inp.started	= true;
				b			= true;
			else
				b	= false;
			end
		end
		%-----------------------------------------------------------------------%
		function b = Stop(inp)
		% b = inp.Stop
			inp.started	= false;
			b			= true;
		end
		%-----------------------------------------------------------------------%
		function [t,x] = Read(inp)
		% [t,x] = inp.Read
			if inp.started
				t	= inp.Now - inp.tStart + (0:1/inp.rate:inp.duration)';
				x	= zeros(size(t));
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
			t	= PTB.Now/1000;
		end
		%-----------------------------------------------------------------------%
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
