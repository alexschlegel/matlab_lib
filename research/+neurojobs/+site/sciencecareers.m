function [s,extra] = sciencecareers(query)
% neurojobs.site.sciencecareers
% 
% Syntax:	[s,extra] = neurojobs.site.sciencecareers(query)
% 
% Updated: 2014-09-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
url				= 'http://jobs.sciencecareers.org/jobsrss/?Discipline=24%2c67%2c513099&PositionType=201&JobType=216%2c224%2c225&countrycode=US';
[node,extra]	= neurojobs.site.fetch(url);

item	= neurojobs.parse.extract(node,'item','type','tag');

cInfo	= neurojobs.parse.extract(item,'title','type','tag','return','text');
cLink	= neurojobs.parse.extract(item,'guid','type','tag','return','text');
cDate	= neurojobs.parse.extract(item,'pubdate','type','tag','return','text');

nResult	= numel(cInfo);

s	= repmat(neurojobs.result.blank,[nResult 1]);

for kR=1:nResult
	ifo	= regexp(cInfo{kR},'(?<loc>.+)[\s]*: (?<title>.+)','names');
	
	s(kR).date		= FormatTime(getfield(regexp(cDate{kR},'(?<date>\d+ \w+ \d+ \d+:\d+:\d+)','names'),'date'));
	s(kR).title		= ifo.title;
	s(kR).location	= ifo.loc;
	s(kR).url		= cLink{kR};
end
