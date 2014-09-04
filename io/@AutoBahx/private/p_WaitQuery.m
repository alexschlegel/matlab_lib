function bReady = p_WaitQuery(ab,bTimeout)
% p_WaitSerial
% 
% Description:	wait for other serial processes to finish
% 
% Syntax:	bReady = p_WaitQuery(ab,bTimeout)
% 
% Updated: 2012-03-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
tStart	= PTB.Now;

while ab.serial_busy && (~bTimeout || PTB.Now<tStart + ab.TIMEOUT_WAIT)
	%disp([bTimeout PTB.Now<tStart + ab.TIMEOUT_WAIT]);
	WaitSecs(0.001);
end
%disp([bTimeout PTB.Now<tStart + ab.TIMEOUT_WAIT 1]);

if ~bTimeout || PTB.Now<tStart + ab.TIMEOUT_WAIT
	p_Flush(ab);
	
	bReady	= true;
else
	bReady	= false;
end
