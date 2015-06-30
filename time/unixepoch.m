function t = unixepoch()
% unixepoch
%
% Description:	return the unix epoch time in nowms style
%
% Syntax:	t = unixepoch
%
% Updated: 2015-06-25
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent tEpoch;

if isempty(tEpoch)
	tEpoch	= FormatTime('1970-01-01');
end

t	= tEpoch;
