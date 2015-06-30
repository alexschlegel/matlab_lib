function Connect(com)
% Communicator.Connect
% 
% Description:	connect to the other party
% 
% Syntax:	com.Connect()
% 
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch com.mode
	case 'client'
		while ~com.connected
			try
				fopen(com.tcpip);
				pause(com.WAIT_LONG);
			catch me
				pause(com.WAIT_LONG);
			end
		end
	case 'server'
		fopen(com.tcpip);
end
