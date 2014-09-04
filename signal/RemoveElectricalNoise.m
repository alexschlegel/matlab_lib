function x = RemoveElectricalNoise(x,fs)
% RemoveElectricalNoise
% 
% Description:	remove 60Hz noise from a sample
% 
% Syntax:	x = RemoveElectricalNoise(x,fs)
% 
% In:
% 	x	- the sample
%	fs	- the sampling frequency
% 
% Out:
% 	x	- the sample with electrical noise removed
% 
% Updated:	2008-11-23
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
x	= FilterOut(x,60,fs);
