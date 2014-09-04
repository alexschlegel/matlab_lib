function b = Ping(ab,byte)
% AutoBahx.Ping
% 
% Description:	test whether we can communicate with the AutoBahx
% 
% Syntax:	b = ab.Ping(byte)
%
% In:
%	byte	- the byte to send
%
% Out:
%	b	- true if byte was received
% 
% Updated: 2012-01-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
warning('off','MATLAB:serial:fread:unsuccessfulRead');

to	= get(ab.serial,'Timeout');
set(ab.serial,'Timeout',0.1);

byteR	= p_Query(ab,1,'uchar',ab.CMD_PING,byte);

p_Flush(ab);

b	= isequal(byteR,byte);

set(ab.serial,'Timeout',to);
