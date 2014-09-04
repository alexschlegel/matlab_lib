function Connect(com)
% Communicator.Connect
% 
% Description:	connect to the other party
% 
% Syntax:	com.Connect()
% 
% Updated: 2014-01-29
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch com.mode
	case 'client'
		com.L.Print(sprintf('connecting to %s:%d',com.remote.ip, com.remote.port),'info');
		
		while ~com.connected
			try
				fopen(com.tcpip);
				pause(com.WAIT);
				com.Test();
			catch me
				pause(com.WAIT);
			end
		end
	case 'server'
		com.L.Print(sprintf('listening for a connection on port %d',com.remote.port),'info');
		
		fopen(com.tcpip);
end

com.L.Print('connection established','info');
