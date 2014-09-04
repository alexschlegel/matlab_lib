function p_Flush(ab)
% p_Flush
% 
% Description:	flush the incoming serial buffer
% 
% Syntax:	p_Flush(ab)
% 
% Updated: 2012-01-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ab.serial.BytesAvailable>0
	fread(ab.serial,ab.serial.BytesAvailable);
end
