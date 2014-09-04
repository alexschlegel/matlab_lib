function [d,t] = Peek(ser,d)
% PTB.Serial.Peek
% 
% Description:	check for data in the serial buffer without removing it from the
%				buffer
% 
% Syntax:	[d,t] = ser.Peek(d)
% 
% In:
%	d	- the data values to check for
%
% Out:
%	d	- an Nx1 array of data values found
%	t	- an Nx1 array of the PTB.Now times at which the values in d were
%		  recorded
%
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

%update the buffer
	switch ser.hPort
		case {ser.PORT_NONE,ser.PORT_FAKE}
		otherwise
		%read from the port
			[dRead,tRead,strErr]	= IOPort('Read',hPort);
			
			PTBIFO.serial.buffer_data	= [PTBIFO.serial.buffer_data; reshape(dRead,[],1)];
			PTBIFO.serial.buffer_time	= [PTBIFO.serial.buffer_time; reshape(getsecs2ms(tRead),[],1)];
			
			if ~isempty(strErr)
				ser.AddLog(['ioport error (' strErr ')']);
			end
	end

%search for the data
	b	= ismember(PTBIFO.serial.buffer_data,d);
	
	d	= PTBIFO.serial.buffer_data(b);
	t	= PTBIFO.serial.buffer_time(b);
