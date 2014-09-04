function b = Close(ser)
% PTB.Serial.Close
% 
% Description:	close the serial port
% 
% Syntax:	b = ser.Close
% 
% Out:
%	b	- true if the port was successfully closed
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strPort	= ser.parent.Info.Get('serial','port');

b	= false;

if isempty(strPort)
	return;
end

switch strPort
	case {ser.PORT_NONE,ser.PORT_FAKE}
	%do nothing
		
	otherwise
	%close an actual serial port
		try
			IOPort('Close',ser.hPort);
		catch me
			ser.AddLog(['close port error (' me.message ')']);
			return;
		end
end

b	= true;
