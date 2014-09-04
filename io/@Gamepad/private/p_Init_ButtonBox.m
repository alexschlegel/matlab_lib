function gp = p_Init_ButtonBox(gp,nGP,varargin)
% p_Init_ButtonBox
% 
% Description:	init the button box
% 
% Syntax:	gp = p_Init_ButtonBox(gp,nGP,[kPort]=1)
% 
% In:
% 	gp		- the gamepad object
%	nGP		- the current number of gamepad objects
%	kPort	- the COM port number
% 
% Out:
% 	gp	- the updated gamepad object
% 
% Updated: 2011-09-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
kPort	= ParseArgs(varargin,1);
strPort	= ['COM' num2str(kPort)];

%open the serial port
	IOPort('Verbosity', 10);
	
	gp.param.h	= IOPort('OpenSerialPort',strPort,'BaudRate=115200');
%flush the event buffer
	IOPort('Flush', gp.param.h);
