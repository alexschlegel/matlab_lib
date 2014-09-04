function t	= Now
% Group.Now
% 
% Description:	return the number of milliseconds since 00:00 January 1 0AD with
%				the precision of GetSecs if it is on the MATLAB path
% 
% Syntax:	t	= Group.Now
% 
% Updated: 2011-12-26
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent bUseGetSecs;
global gsms_msStart gsms_gsStart;

if isempty(bUseGetSecs)
	bUseGetSecs	= exist('GetSecs')==3;
end

if bUseGetSecs
	t	= GetSecs;
	
	if isempty(gsms_msStart)
		gsms_msStart	= nowms;
		gsms_gsStart	= GetSecs;
	end
	
	t	= (t - gsms_gsStart)*1000 + gsms_msStart;
else
	t	= now*86400000;
end
