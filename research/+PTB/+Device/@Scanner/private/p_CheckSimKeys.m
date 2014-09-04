function p_CheckSimKeys(scn)
% p_CheckSimKeys
% 
% Description:	check for the scanner simulation button box keys and fake serial
%				data if they have been pressed
% 
% Syntax:	p_CheckSimKeys(scn)
% 
% Updated: 2012-12-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%blue
	[b,err,t]	= scn.parent.Input.Key.DownOnce('bb_blue',false);
	if b
		scn.parent.Serial.Fake(scn.SCANNER_BB_BLUE,t);
	end
%yellow
	[b,err,t]	= scn.parent.Input.Key.DownOnce('bb_yellow',false);
	if b
		scn.parent.Serial.Fake(scn.SCANNER_BB_YELLOW,t);
	end
%green
	[b,err,t]	= scn.parent.Input.Key.DownOnce('bb_green',false);
	if b
		scn.parent.Serial.Fake(scn.SCANNER_BB_GREEN,t);
	end
%red
	[b,err,t]	= scn.parent.Input.Key.DownOnce('bb_red',false);
	if b
		scn.parent.Serial.Fake(scn.SCANNER_BB_RED,t);
	end
