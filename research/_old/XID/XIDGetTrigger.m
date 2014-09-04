function b = XIDGetTrigger(s,k)
% XIDGetTrigger
% 
% Description:	get the state of the specified trigger
% 
% Syntax:	b = XIDGetTrigger(s,k)
% 
% Updated: 2010-06-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
res		= XIDQuery(s,'_ah');
b		= bitget(res(end),k);
