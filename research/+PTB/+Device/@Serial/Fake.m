function Fake(ser,d,varargin)
% PTB.Serial.Fake
% 
% Description:	fake data into the buffer
% 
% Syntax:	ser.Fake(d,[t]=<now>)
% 
% In:
%	d	- an array of data values to add
%	[t]	- the time to associate with the data
%
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if numel(varargin)>0
	t	= varargin{1};
else
	t	= PTB.Now;
end

d	= reshape(d,[],1);
n	= numel(d);
t	= repto(reshape(t,[],1),[n 1]);

PTBIFO.serial.buffer_data	= [PTBIFO.serial.buffer_data; d];
PTBIFO.serial.buffer_time	= [PTBIFO.serial.buffer_time; t];
