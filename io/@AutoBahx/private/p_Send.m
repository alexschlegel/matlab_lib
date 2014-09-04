function b = p_Send(ab,cmd,varargin)
% p_Send
% 
% Description:	send a command to the AutoBahx
% 
% Syntax:	b = p_Send(ab,cmd,[ext]=[])
% 
% In:
% 	ab	- the AutoBahx object
%	cmd	- the command byte
%	ext	- extra info about the command
% 
% Out:
% 	b	- true if the command was successfully sent
% 
% Updated: 2012-01-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ext		= ParseArgs(varargin,[]);
nExtra	= numel(ext);

try
	byteSend	= [cmd reshape(ext,1,nExtra)];
	
	fwrite(ab.serial,byteSend,'uchar');
	
	b	= true;
catch me
	b	= false;
end
