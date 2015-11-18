function [s,extra] = chroniclevitae(query)
% neurojobs.site.chroniclevitae
% 
% Syntax:	[s,extra] = neurojobs.site.chroniclevitae(query)
% 
% Updated: 2015-10-28
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
url				= ['https://chroniclevitae.com/job_search?job_search[keywords]=' query '&job_search[distance_from_zip]=10&job_search[position_type]=1'];
[node,extra]	= neurojobs.site.fetch(url);

li			= neurojobs.parse.extract(node,'search-result','tag','li');
job			= neurojobs.parse.extract(li,'search-result--job','tag','li');

nResult	= job.size;

s	= repmat(neurojobs.result.blank,[nResult 1]);

for kR=1:nResult
	jobCur	= job.get(kR-1);
	
	strDate			= char(neurojobs.parse.extract(jobCur,'search-result__date','return','text'));
	
	s(kR).date		= FormatTime(getfield(regexp(strDate,'(?<date>\d+/\d+/\d+)','names'),'date'));
	s(kR).title		= char(neurojobs.parse.extract(jobCur,'search-result__title','return','text'));
	s(kR).location	= char(neurojobs.parse.extract(jobCur,'search-result__location','return','text'));
	s(kR).url		= char(neurojobs.parse.extract(jobCur,'a','type','tag','return','href'));
end
