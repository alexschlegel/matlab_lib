function XIDSetTrigger(s,k,b)
% XIDSetTrigger
% 
% Description:	set the state of the specified trigger
% 
% Syntax:	XIDSetTrigger(s,k,b)
% 
% Updated: 2010-06-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the current trigger states
	res		= XIDQuery(s,'_ah');
	tState	= res(end);
%set the specified trigger's state
	tState	= bitset(tState,k,b);
%send the updated state until we're successful
	tStateNew	= tState-1;
	while tStateNew~=tState
		XIDSend(s,['ah' tState]);
		
		resNew		= XIDQuery(s,'_ah');
		tStateNew	= resNew(end);
	end
