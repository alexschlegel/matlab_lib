function Calibrate(ab)
% AutoBahx.Calibrate
% 
% Description:	calibrate MATLAB and AutoBahx time
% 
% Syntax:	ab.Calibrate
% 
% Updated: 2014-03-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent tM tA

if isempty(ab.calibrate_k)
%fill the calibration array during the first call
	[tM,tA]	= deal(NaN(ab.N_CALIBRATE,1));
	
	kCCur	= 0;
	for kC=1:ab.N_CALIBRATE
		[tMCur,tACur]	= GetCalibrationPoint();
		
		if ~isempty(tMCur)
			kCCur	= kCCur + 1;
			
			tM(kCCur)	= tMCur;
			tA(kCCur)	= tACur;
		end
	end
	
	if ~isempty(tM)
		ab.calibrate_k	= 1;
	end
else
%get another calibration point
	[tMCur,tACur]	= GetCalibrationPoint();
	
	if ~isempty(tMCur)
		tM(ab.calibrate_k)	= tMCur;
		tA(ab.calibrate_k)	= tACur;
		
		ab.calibrate_k		= mod(ab.calibrate_k,ab.N_CALIBRATE)+1;
	end
end

%fit a calibration line
	[r,stat]	= corrcoef2(tA,tM');
	
	ab.calibrate_m	= stat.m;
	ab.calibrate_b	= stat.b;
	
% 	disp([num2str(ab.calibrate_m) ' ' FormatTime(ab.calibrate_b,'yyyy-mm-dd HH:MM:SS.FFF')]);
% 	if ab.calibrate_k>10
% 		disp([tM(ab.calibrate_k+(-10:-1)) tA(ab.calibrate_k+(-10:-1))]);
% 	end

%------------------------------------------------------------------------------%
function [tMPoint,tAPoint] = GetCalibrationPoint()
	t1	= PTB.Now;
	
	[nOverflow,tMicros]	= p_QueryTime(ab,ab.CMD_TIME,false,true);
	
	if ~isempty(nOverflow)
		t2	= PTB.Now;
		
		tMPoint	= (t1+t2)/2;
		tAPoint	= p_boxu2boxm(ab,nOverflow,tMicros);
	else
		[tMPoint,tAPoint]	= deal([]);
	end
end
%------------------------------------------------------------------------------%

end
