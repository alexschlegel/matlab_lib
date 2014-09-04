function t = session2time(strSession,varargin)
% session2time
% 
% Description:	convert a session code to a time as milliseconds from the epoch
% 
% Syntax:	t = session2time(strSession,<options>)
% 
% In:
% 	strSession	- the session code as DDMMMYY<subject>, e.g. 11oct81as
%	<options>:
%		timeofday:	(0.5) the time of day as fraction of a day or as a time
%					string
% 
% Out:
% 	t	- the time of the session as milliseconds from the epoch
% 
% Updated: 2010-12-02
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
t	= ParseSessionCode(strSession,varargin{:});
