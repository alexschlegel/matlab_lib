function t = getsecs2ms(gs)
% getsecs2ms
% 
% Description:	convert a GetSecs style time to a nowms style serial time
% 
% Syntax:	t = getsecs2ms(gs)
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global gsms_msStart gsms_gsStart;

if isempty(gsms_msStart)
	gsms_msStart	= nowms;
	gsms_gsStart	= GetSecs;
end

t	= (gs - gsms_gsStart)*1000 + gsms_msStart;
