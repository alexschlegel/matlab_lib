function t1 = TimeAlign(t1,t1Ref1,t1Ref2,t2Ref1,t2Ref2)
% TimeAlign
% 
% Description:	convert times from one time space to another time spaces
% 
% Syntax:	t2 = TimeAlign(t1,t1Ref1,t1Ref2,t2Ref1,t2Ref2)
% 
% In:
% 	t1			- the times in the first time space
%	t1Ref1/2	- two times in the first time space
%	t2Ref1/2	- two times in the second time space corresponding to trRef1/2
%
% Out:
% 	t2	- t1 in the second time space
% 
% Updated: 2010-07-22
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%shift and scale the times
	t1	= (t1-t1Ref1).*(t2Ref2-t2Ref1)./(t1Ref2-t1Ref1) + t2Ref1;
	