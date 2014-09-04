function varargout = forkOutput(h)
% forkOutput
% 
% Description:	get the output from a call to fork
% 
% Syntax:	[x1,...,xN] = forkOutput(h)
% 
% In:
% 	h	- the output from a call to fork
% 
% Out:
% 	xK	- the Kth output
% 
% Updated: 2014-02-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
varargout	= unless(get(h,'UserData'),cell(nargout,1));

try
	stop(h);
	delete(h);
catch me
end
