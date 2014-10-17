classdef Serial < PTB.Object
% PTB.Device.Serial
% 
% Description:	access a serial port
% 
% Syntax:	ser = PTB.Device.Serial(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Open:				open the serial port
%				Close:				close the serial port
%				Check:				check for the presence of data in the input
%									buffer
%				Peek:				check for the presence of data in the input
%									buffer without removing it from the buffer
%				Fake:				send fake data to the input buffer
%				Clear:				clear the data buffer
% 
% In:
%	parent	- the parent object
% 	<options:
%		serial_open:		(<auto>) true to open the serial port
%		serial_port:		(<auto>) a string specifying the serial port (see
%							IOPort('OpenSerialPort?'))
%		serial_baudrate:	(<auto>) the serial baud rate, in bps
% 
% Updated: 2012-02-11
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%CONSTANT PROPERTIES-------------------------------------------------------%
	properties (Constant)
		%serial port constants
			PORT_FAKE	= -1;
			PORT_NONE	= -2;
	end
	%CONSTANT PROPERTIES-------------------------------------------------------%
	
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		hPort	= PTB.Device.Serial.PORT_NONE;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function ser = Serial(parent)
			ser	= ser@PTB.Object(parent,'serial');
		end
		%----------------------------------------------------------------------%
		function Start(ser,varargin)
		% start the serial object
			opt	= ParseArgs(varargin,...
					'serial_open'		, []	, ...
					'serial_port'		, []	, ...
					'serial_baudrate'	, []	, ...
					'scanner_simulate'	, []	  ...
					);
			
			strContext	= ser.parent.Info.Get('experiment','context');
			dbg			= ser.parent.Info.Get('experiment','debug');
			
			bScannerSim	= unless(opt.scanner_simulate,isequal(strContext,'fmri') && dbg>1);
			bExists		= ~isempty(ser.parent.Info.Get('serial','port'));
			
			if isempty(opt.serial_open)
				opt.serial_open	= isequal(strContext,'fmri');
			end
			
			ser.parent.Info.Set('serial','open',opt.serial_open,'replace',false);
			
			if isempty(opt.serial_port)
				if ser.parent.Info.Get('serial','open')
					if dbg>1 || (isequal(strContext,'fmri') && bScannerSim)
						opt.serial_port	= ser.PORT_FAKE;
					else
						if ispc
							opt.serial_port	= 'COM1';
						elseif isunix
							opt.serial_port	= '/dev/ttyS0';
						else
							error('I know not about serial ports on this operating system.  You need to manually specify it.');
						end
					end
				else
					opt.serial_port	= ser.PORT_NONE;
				end
			end
			
			if isempty(opt.serial_baudrate)
				opt.serial_baudrate	= 115200;
			end
			
			ser.parent.Info.Set('serial','port',opt.serial_port,'replace',false);
			ser.parent.Info.Set('serial','baudrate',opt.serial_baudrate,'replace',false);
			
			%clear the buffer
				ser.parent.Info.Set('serial','buffer_time',[],'replace',false);
				ser.parent.Info.Set('serial','buffer_data',[],'replace',false);
			%close all ports
				IOPort('CloseAll');
			%open the serial port
				if ~ser.Open(~bExists,~bExists)
					error('Could not open the serial port.  You may need to manually specify it.');
				end
		end
		%----------------------------------------------------------------------%
		function End(ser,varargin)
		% end the serial object
			%close the port
				ser.Close;
			%close all ports
				IOPort('CloseAll');
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
