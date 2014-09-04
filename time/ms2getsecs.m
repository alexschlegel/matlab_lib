function t = ms2getsecs(ms)
% ms2getsecs
% 
% Description:	convert a nowms style serial time to a GetSecs style time
% 
% Syntax:	t = ms2getsecs(ms)
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

t	= (ms - gsms_msStart)/1000 + gsms_gsStart;
