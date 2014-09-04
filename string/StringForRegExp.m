function str = StringForRegExp(str)
% StringForRegExp
% 
% Description:	format str for literal interpretation in a regexp pattern
% 
% Syntax:	str = StringForRegExp(str)
% 
% Updated:	2009-03-10
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

chrReplace	= '\()[]*?+|{}.^$';
nReplace	= numel(chrReplace);

for kR=1:nReplace
	chr			= chrReplace(kR);
	strReplace	= ['\' chr];
	
	str	= strrep(str,chr,strReplace);
end
