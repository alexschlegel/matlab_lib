function PauseCalibration(ab)
% AutoBahx.PauseCalibration
% 
% Description:	pause the AutoBahx time calibration procedure
% 
% Syntax:	ab.PauseCalibration()
% 
% Updated: 2012-01-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if IsTimerRunning(ab.calibration_timer)
	stop(ab.calibration_timer);
end
