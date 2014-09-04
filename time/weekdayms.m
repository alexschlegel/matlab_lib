function varargout = weekdayms(varargin)
% weekdayms
% 
% Description:	get the day of week of a date stored as number of milliseconds
%				since the epoch
% 
% Syntax:	see weekday for syntax
% 
% Updated: 2011-10-13
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%convert the date to a serial date
	varargin{1}	= varargin{1} / 86400000;

[varargout{1:nargout}]	= weekday(varargin{:});