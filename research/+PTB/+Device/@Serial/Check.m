function [d,t] = Check(ser,d)
% PTB.Serial.Check
% 
% Description:	check for data in the serial buffer
% 
% Syntax:	[d,t] = ser.Check(d)
% 
% In:
%	d	- the data values to check for
%
% Out:
%	d	- an Nx1 array of data values found
%	t	- an Nx1 array of the PTB.Now times at which the values in d were
%		  recorded
%
% Side-effects:	removes found data from the buffer
% 
% Updated: 2012-02-11
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

%update the buffer
	switch ser.hPort
		case {ser.PORT_NONE,ser.PORT_FAKE}
		otherwise
		%read from the port
			[dRead,tRead,strErr]	= IOPort('Read',ser.hPort);
			
			nRead	= numel(dRead);
			
			if ~isempty(dRead)
				tRead	= getsecs2ms(tRead);
				
				dRead	= reshape(dRead,nRead,1);
				tRead	= repto(reshape(tRead,[],1),[nRead 1]);
				
				PTBIFO.serial.buffer_data	= [PTBIFO.serial.buffer_data; dRead];
				PTBIFO.serial.buffer_time	= [PTBIFO.serial.buffer_time; tRead];
			end
			
			if ~isempty(strErr)
				ser.AddLog(['ioport error (' strErr ')']);
			end
	end

%search for the data
	b	= ismember(PTBIFO.serial.buffer_data,d);
	
	d	= PTBIFO.serial.buffer_data(b);
	t	= PTBIFO.serial.buffer_time(b);
%remove found data from the buffer
	PTBIFO.serial.buffer_data(b)	= [];
	PTBIFO.serial.buffer_time(b)	= [];
