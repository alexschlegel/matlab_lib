function [b,t] = settrigger(baseAddr,kPin)
% settrigger
% 
% Description:	set pins in the PCI-DIO-24 to BioSemi USB module trigger system
%				(Linux only)
% 
% Syntax:	[b,t] = settrigger(baseAddr,kPin)
% 
% In:
% 	baseAddr	- the base address of the PCI-DIO-24 card, as a hexadecimal
%				  string.  use pcifind.plx to determine this (d880 currently).
%	kPin		- an array of pins (1->16) to set high
%
% Out:
%	b	- true if the trigger was successfully sent
%	t	- the trigger time
% 
% Updated: 2012-03-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t1	= PTB.Now;
b	= ~system(['/bin/settrigger ' baseAddr ' ' num2str(kPin)]);
t2	= PTB.Now;

t	= (t1+t2)/2;
