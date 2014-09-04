function SetRGB(a,pin,col)
% Arduino.SetRGB
% 
% Description:	set an RGB LED color
% 
% Syntax:	SetRGB(a,pin,col)
% 
% In:
%	a	- the arduino object
% 	pin	- a three element array of the R, G, and B pins
%	col	- the [R G B] (0->255) color
% 
% Updated: 2012-01-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
for k=1:numel(pin)
	a.analogWrite(pin(k),col(k));
end
