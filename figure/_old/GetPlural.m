function str = GetPlural(n,strP,strS)
% GetPlural
% 
% Description:	return strS if |n|==1, strP otherwise
% 
% Syntax:	str = GetPlural(n,strP,strS)
% 
% Updated:	2009-01-13
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if n==1
	str	= strS;
else
	str	= strP;
end
