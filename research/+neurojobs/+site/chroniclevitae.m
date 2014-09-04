function [s,extra] = chroniclevitae(query)
% neurojobs.site.chroniclevitae
% 
% Syntax:	[s,extra] = neurojobs.site.chroniclevitae(query)
% 
% Updated: 2014-09-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
url				= ['https://chroniclevitae.com/job_search?job_search[keywords]=' query '&job_search[distance_from_zip]=10&job_search[position_type]=1'];
[node,extra]	= neurojobs.site.fetch(url);

li			= neurojobs.parse.extract(node,'search-result','tag','li');
cLink		= neurojobs.parse.extract(li,'a','type','tag','return','href');
cTitle		= neurojobs.parse.extract(node,'search-result__title','return','text');
cLocation	= neurojobs.parse.extract(node,'search-result__location','return','text');
cDate		= neurojobs.parse.extract(node,'search-result__date','return','text');

nResult	= numel(cTitle);

s	= repmat(neurojobs.result.blank,[nResult 1]);

for kR=1:nResult
	s(kR).date		= FormatTime(getfield(regexp(cDate{kR},'(?<date>\d+/\d+/\d+)','names'),'date'));
	s(kR).title		= cTitle{kR};
	s(kR).location	= cLocation{kR};
	s(kR).url		= cLink{kR};
end
