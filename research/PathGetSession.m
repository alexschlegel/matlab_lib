function strSession = PathGetSession(strPath)
% PathGetSession
% 
% Description:	find a session code in a file path
% 
% Syntax:	strSession = PathGetSession(strPath)
% 
% Updated: 2015-03-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent re cMonths

if isempty(re)
	%treat "o" as "0"
		re	= '[0123Oo][\dOo][A-Za-z]{3}[\dOo]{2}\w{2,3}';
	
	cMonths	= {'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'};
end

s	= regexp(strPath,re,'match');

if ~isempty(s) && ismember(s{1}(3:5),cMonths)
	strSession	= s{1};
else
	strSession	= PathGetFilePre(strPath,'favor','nii.gz');
end
