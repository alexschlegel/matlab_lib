function res = XIDQuery(s,strQuery,varargin)
% XIDQuery
% 
% Description:	query an XID connection
% 
% Syntax:	res = XIDQuery(s,strQuery,<options>)
% 
% In:
% 	s			- the XID connection
%	strQuery	- the query string
% 
% Out:
% 	res	- the response array
% 
% Updated: 2010-06-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%clear the buffer
	if s.BytesAvailable>0
		dummy	= fread(s,s.BytesAvailable);
	end
%send the query
	fwrite(s,[strQuery 13]);
%wait for a response
	tStart	= nows;
	while nows<tStart+s.Timeout
		if s.BytesAvailable>1
			break;
		end
	end
%read the result
	if s.BytesAvailable
		res	= fread(s,s.BytesAvailable)';
	else
		error('Serial timeout occurred');
	end
