function b = Open(ser,varargin)
% PTB.Serial.Open
% 
% Description:	open the serial port
% 
% Syntax:	b = ser.Open([bClearSerial]=true,[bClearPrivate]=true)
%
% In:
%	[bClearSerial]	- clear the serial buffer
%	[bClearPrivate]	- clear the private buffer
% 
% Out:
%	b	- true if the port was successfully opened
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strPort		= ser.parent.Info.Get('serial','port');
baudRate	= ser.parent.Info.Get('serial','baudrate');

b	= false;

[bClearSerial,bClearPrivate]	= ParseArgs(varargin,true,true);

if isempty(strPort)
	return;
end

switch strPort
	case ser.PORT_NONE
	%don't open the serial port
		ser.hPort	= ser.PORT_NONE;
	case ser.PORT_FAKE
	%fake the serial port
		ser.hPort	= ser.PORT_FAKE;
		
		ser.AddLog(['opened (fake)']);
	otherwise
	%open an actual serial port
		strBaudRate	= ['BaudRate=' num2str(baudRate)];
		
		%open the serial port
			IOPort('Verbosity', 10);
			
			try
				ser.hPort	= IOPort('OpenSerialPort',strPort,strBaudRate);
			catch me
				ser.AddLog(['openserialport error (' me.message ')']);
				return;
			end
			
			ser.AddLog(['opened (' tostring(strPort) ')']); 
			
			ser.parent.Info.Set('serial','h',ser.hPort);
		%clear the data buffer
			ser.Clear(bClearSerial,bClearPrivate);
end

b	= true;
