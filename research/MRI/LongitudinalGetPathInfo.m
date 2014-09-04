function [strInit,kSession] = LongitudinalGetPathInfo(strPathData)
% LongitudinalGetPathInfo
% 
% Description:	extract session info from a longitudinal-formatted path (i.e.
%				one of the form .../<init>/<session>/...
% 
% Syntax:	[strInit,kSession] = LongitudinalGetPathInfo(strPathData)
% 
% In:
% 	strPathData	- the path to a data file or directory in a
%				  longitudinal-formatted directory tree
% 
% Out:
% 	strInit		- the subject's initials
%	kSession	- the session number
% 
% Updated: 2011-10-29
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
re	= '(?<init>[A-Za-z0-9]+)[/\\](?<session>[0-9]+)';
s	= regexp(strPathData,re,'names');

if ~isempty(s)
	strInit		= s(end).init;
	kSession	= str2num(s(end).session);
else
	strInit		= '';
	kSession	= NaN;
end
