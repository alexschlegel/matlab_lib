function arm(cap,nCapture)
% capture.base.arm
% 
% Description:	prepare the capture device for capturing
% 
% Syntax:	cap.arm(nCapture)
%
% In:
%	nCapture	- the number of captures to prepare for. 0 should be treated
%				  like 1.
% 
% Updated: 2013-07-28
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ~cap.armed
	cap.armed	= true;
end
