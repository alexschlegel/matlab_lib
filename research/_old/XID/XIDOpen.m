function s = XIDOpen(strPort)
% XIDOpen
% 
% Description:	open a serial port for XID communication
% 
% Syntax:	s = XIDOpen(strPort)
% 
% In:
% 	strPort	- a string describing the port
% 
% Out:
% 	s	- the serial object set up for XID communication
% 
% Updated: 2010-06-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get a reference to the serial port object
	s = serial(strPort,'BaudRate',115200,'DataBits',8,'StopBits',1,'FlowControl','software','Parity','none','Terminator','CR','Timeout',1,'InputBufferSize',16000);
%open the port
	fopen(s);
%set it up for XID communication
	XIDSend(s,'c10');
