function Clear(ser,varargin)
% PTB.Serial.Clear
% 
% Description:	clear the serial buffer
% 
% Syntax:	ser.Clear([bClearSerial]=true,[bClearPrivate]=true)
%
% In:
%	[bClearSerial]	- clear the serial buffer
%	[bClearPrivate]	- clear the private buffer
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[bClearSerial,bClearPrivate]	= ParseArgs(varargin,true,true);

if bClearSerial
%clear the actual buffer
	ser.Check(1:255);
end

if bClearPrivate
%clear our private buffer
	ser.parent.Info.Set('serial','buffer_data',[]);
	ser.parent.Info.Set('serial','buffer_time',[]);
end
