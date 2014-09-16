function [s,extra] = academicjobs(query)
% neurojobs.site.academicjobs
% 
% Syntax:	[s,extra] = neurojobs.site.academicjobs(query)
% 
% Updated: 2014-09-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
url				= ['https://academicjobsonline.org/ajo?joblist-0-0-0----40-p&id=' query];
[node,extra]	= neurojobs.site.fetch(url);

[cLocation,cInfo,cLink,cDate]	= deal({});

dt	= neurojobs.parse.extract(node,'clr','tag','dt');
nDT	= dt.size;

for kD=1:nDT
	dtCur	= dt.get(kD-1);
	
	li	= neurojobs.parse.extract(dtCur,'li','type','tag');
	
	loc		= neurojobs.parse.extract(dtCur,'b','type','tag','return','html');
	ifo		= neurojobs.parse.extract(dtCur,'li','type','tag','return','text');
	lnk		= neurojobs.parse.extract(li,'a','type','tag','return','href');
	lnkText	= neurojobs.parse.extract(li,'a','type','tag','return','text');
	lnk		= lnk(cellfun(@(str) ~isequal(lower(str),'apply'),lnkText));
	dat		= neurojobs.parse.extract(li,'purplesml','tag','span','return','html');
	
	nEntry		= numel(dat);
	
	cLocation	= [cLocation; repto(loc,[nEntry 1])];
	cInfo		= [cInfo; repto(ifo,[nEntry 1])];
	cLink		= [cLink; repto(lnk,[nEntry 1])];
	cDate		= [cDate; repto(dat,[nEntry 1])];
end

nResult	= numel(cInfo);

s	= repmat(neurojobs.result.blank,[nResult 1]);

for kR=1:nResult
	s(kR).date		= FormatTime(getfield(regexp(cDate{kR},'(?<date>\d+/\d+/\d+)\)$','names'),'date'));
	s(kR).title		= StringTrim(getfield(regexp(cInfo{kR},'\[\] (?<title>.+)','names'),'title'));
	
	cLoc			= regexp(cLocation{kR},'<a[^>]+>(?<loc>[^<]+)','names');
	s(kR).location	= join({cLoc.loc},', ');
	s(kR).url		= sprintf('https://academicjobsonline.org%s',cLink{kR});
end
