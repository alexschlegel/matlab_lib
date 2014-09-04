function XIDPulseTrigger(s,k,varargin)
% XIDPulseTrigger
% 
% Description:	pulse a trigger over an XID connection
% 
% Syntax:	XIDPulseTrigger(s,k,<options>)
% 
% In:
% 	s	- the XID connection object
%	k	- the trigger to pulse (1-based)
%	<options>:
%		t			: (50) time to wait before releasing the pulse, in ms
%		reflective	: (true) true if the device is currently in reflective mode
% 
% Updated: 2010-06-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		't'				, 50	, ...
		'reflective'	, true	  ...
		);

%switch to general mode
	if opt.reflective
		XIDSend(s,'a10');
	end
%start the pulse
	XIDSetTrigger(s,k,true);
%wait
	pause(opt.t/1000);
%end the pulse
	XIDSetTrigger(s,k,false);
%switch back to reflective mode
	if opt.reflective
		XIDSend(s,'a11');
	end
