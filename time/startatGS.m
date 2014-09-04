function startatGS(tmr,gs)
% startatGS
% 
% Description:	version of startat that takes a GetSecs style time as the start
%				time (see startat)
% 
% Syntax:	startatGS(tmr,gs)
% 
% Updated: 2011-12-14
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
startat(tmr,getsecs2serial(gs));
