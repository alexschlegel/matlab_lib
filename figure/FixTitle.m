function strTitle = FixTitle(strTitle)
% FixTitle
% 
% Description:	fix strTitle so it works well in a plot title
% 
% Syntax:	strTitle = FixTitle(strTitle)
% 
% Updated:	2008-11-12
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

cReplace	= {'\', '{', '}', '_', '^'};
nReplace	= numel(cReplace);

for kReplace=1:nReplace
	strTitle	= strrep(strTitle,cReplace{kReplace},['\' cReplace{kReplace}]);
end
