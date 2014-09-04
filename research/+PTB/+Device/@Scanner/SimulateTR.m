function SimulateTR(scn)
% PTB.Scanner.SimulateTR
% 
% Description:	simulate a TR trigger from the scanner
% 
% Syntax:	scn.SimulateTR
% 
% Updated: 2011-12-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
scn.parent.Serial.Fake(scn.SCANNER_TRIGGER);
