classdef AutoBahx < handle
% AutoBahx
% 
% Description:	control object for the AutoBahx
% 
% Syntax:	ab = AutoBahx(<options>)
% 
% 			subfunctions:
%				Press: 				press the AutoBahx button for a set amount of
%									time
%				GetTimes:			get the button down and up times that have
%									occurred since the last call to GetTimes
%				PauseCalibration:	pause the autocalibration timer
%				ResumeCalibration:	resume the autocalibration timer
%				Calibrate:			manually perform a time calibration step
% 
% 			properties:
% 				color (get/set):	the button LED (r,g,b) color (0->255)
%				button (get/set):	the button state (either boolean for on/off
%									or a number from 0->1 for partial activation
%									(not recommended)
%				opened (get):		true if the serial link with the AutoBahx is
%									opened
%				calibrating (get):	true if the autocalibration timer is enabled
%
%			constants:
%				BAUDRATE:		the baud rate used for communicating with the
%								AutoBahx
%				T_PRESS_MAX:	the maximum Press time, in ms
% 
% In:
% 	<options>:
%		port:	(<auto/ask>) the name of the serial port to use for communication
%				with the AutoBahx
% 
% Updated: 2012-03-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC CONSTANT PROPERTIES------------------------------------------------%
	properties (Constant)
		BAUDRATE	= 115200;
		
		T_PRESS_MAX		= 500;
	end
	properties (GetAccess=protected, Constant)
		CMD_TIME			= 1;
		CMD_COLOR			= 2;
		CMD_BUTTON_GET		= 3;
		CMD_BUTTON_SET		= 4;
		CMD_BUTTON_SETA		= 5;
		CMD_BUTTON_PRESS	= 6;
		CMD_BUTTON_PRESSAT	= 7;
		CMD_BUTTON_DOWNS	= 8;
		CMD_BUTTON_UPS		= 9;
		CMD_PING			= 10;
		
		MICROS_OVERFLOW	= 2^32;
		
		N_CALIBRATE				= 50;
		CALIBRATION_INTERVAL	= 1000;
		
		TIMEOUT_OPEN	= 10000;
		TIMEOUT_READ	= 1000;
		TIMEOUT_WAIT	= 100;
	end
	%PUBLIC CONSTANT PROPERTIES------------------------------------------------%
	
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		color	= [0 0 0];
		button	= 0;
	end
	properties (Dependent)
		opened;
		calibrating;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PROTECTED PROPERTIES------------------------------------------------------%
	properties
		serial;
	end
	properties (SetAccess=protected, GetAccess=protected)
		
		calibration_timer;
		
		calibrate_b	= NaN;
		calibrate_m	= NaN;
		calibrate_k	= [];
		
		serial_busy	= false;
		
		t_down		= [];
		t_up		= [];
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function b = get.opened(ab)
			b	= isequal(get(ab.serial,'Status'),'open') && p_Ping(ab,170);
		end
		%----------------------------------------------------------------------%
		function b = get.calibrating(ab)
			b	= IsTimerRunning(ab.calibration_timer);
		end
		%----------------------------------------------------------------------%
		function set.color(ab,col)
			p_Send(ab,ab.CMD_COLOR,col);
		end
		%----------------------------------------------------------------------%
		function set.button(ab,b)
			if b~=0 && b~=1
				v	= round(MapValue(b,0,1,0,255));
				
				p_Send(ab,ab.CMD_BUTTON_SETA,v);
			else
				p_Send(ab,ab.CMD_BUTTON_SET,b);
			end
			
			ab.button	= b;
		end
		function b = get.button(ab)
			b	= p_Query(ab,1,'uchar',ab.CMD_BUTTON_GET)/255;
		end
		%----------------------------------------------------------------------%
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function ab = AutoBahx(varargin)
			opt	= ParseArgs(varargin,...
					'port'	, []	  ...
					);
			
			%open the port
				status('Opening the port for communication with the AutoBahx');
				b	= p_Open(ab,opt.port);
				
				if ~b
					error('Could not open AutoBahx serial port.');
				end
			%set the timeout
				ab.serial.Timeout	= ab.TIMEOUT_READ/1000;
			%calibrate the AutoBahx time
				status('Calibrating the AutoBahx time');
				ab.Calibrate();
			%create and start the calibration timer
				ab.calibration_timer	= timer(...
					'Name'			, 'autobahx_calibration'	, ...
					'TimerFcn'		, @(varargin) ab.Calibrate	, ...
					'ExecutionMode'	, 'fixedRate'				, ...
					'Period'		, ab.CALIBRATION_INTERVAL/1000	  ...
					);
				startat(ab.calibration_timer,ms2serial(PTB.Now+ab.CALIBRATION_INTERVAL));
		end
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		function delete(ab)
			stop(ab.calibration_timer);
			delete(ab.calibration_timer);
			
			p_Close(ab);
			
			delete@handle(ab);
		end
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
