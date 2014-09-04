function a = STDAwayFromMean(x)
% STDAwayFromMean
% 
% Description:	convert each element of x to how many standard deviations it is
%				away from the mean
% 
% Syntax:	a = STDAwayFromMean(x)
% 
% In:
% 	x	- an array
% 
% Out:
% 	a	- see description
% 
% Updated:	2008-11-23
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
a	= (x - mean(x))./std(x);
