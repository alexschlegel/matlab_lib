function b = Open(ab,varargin)
% AutoBahx.Open
% 
% Description:	open the port for communication with the AutoBahx 
% 
% Syntax:	b = ab.Open([strPort]=<auto>)
%
% In:
%	[strPort]	- the serial port to use for communication with the AutoBahx.  if
%				  unspecified, the function tries to either determine the port
%				  automatically or queries the user.
%
% Out:
%	b	- true if the port was successfully opened
% 
% Updated: 2012-01-18
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strPort	= ParseArgs(varargin,'');

if isempty(strPort)
%auto choose the serial port
	if isunix
		cCheck	=	{
						'/dev/ttyACM0'
						'/dev/ttyUSB0'
					};
	else
		cCheck	= {};
	end
	
	sPorts	= instrhwinfo('serial');
	kPort	= find(ismember(cCheck,sPorts.AvailableSerialPorts),1);
	
	if isempty(kPort)
		strPort	= ask('Enter the serial port for communication with AutoBahx','dialog',false);
	else
		strPort	= cCheck{kPort};
	end
end

%open the port
	if ab.opened
		ab.Close;
	end
	
	ab.serial	= serial(strPort,'BaudRate',ab.BAUDRATE);
	fopen(ab.serial);
	
	%wait until it is opened or we time out
		b		= false;
		tStart	= nowms;
		while ~b && nowms<tStart+ab.TIMEOUT_OPEN
			b	= ab.opened;
		end
