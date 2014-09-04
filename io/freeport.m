function port = freeport(base, varargin)
% freeport
% 
% Description:	find a free tcp/ip port
% 
% Syntax:	port = freeport(base, [nPort]=1)
% 
% In:
% 	base	- the base port number
%	[nPort]	- the number of ports to find
% 
% Out:
% 	port	- an array of free port numbers
% 
% Updated: 2014-01-25
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nPort	= ParseArgs(varargin,1);

port	= NaN(nPort,1);

offset	= 0;
for kP=1:nPort
	bSuccess	= false;
	while ~bSuccess
		pCur	= base + offset;
		
		[ec,out]	= system(['netstat -lnt | awk ''$6 == "LISTEN" && $4 ~ ".' num2str(pCur) '"''']);
		
		bSuccess	= isempty(out);
		offset		= offset + 1;
	end
	
	port(kP)	= pCur;
end
