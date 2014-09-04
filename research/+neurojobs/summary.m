function str = summary(s)
% neurojobs.summary
% 
% Description:	construct a summary of a jobs fetch call
% 
% Syntax:	str = neurojobs.summary(s)
% 
% In:
% 	s	- the result of a call to neurojobs.fetch
% 
% Updated: 2014-08-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nJob	= numel(s);

for kJ=1:nJob
	disp(sprintf('%s: <a href="%s">%s</a> (%s)',FormatTime(s(kJ).date,'yyyy-mm-dd'),s(kJ).url,s(kJ).title,s(kJ).location));
end
