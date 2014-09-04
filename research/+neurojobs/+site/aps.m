function [s,extra] = aps(query)
% neurojobs.site.aps
% 
% Syntax:	[s,extra] = neurojobs.site.aps(query)
% 
% Updated: 2014-09-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
url				= ['http://aps.psychologicalscience.org/jobs/aps_JobsSearchResult-new.cfm?criteria=&startrow=1&first_page_search=yes&search=basic&state=all&subject=' query '&organization=all'];
[node,extra]	= neurojobs.site.fetch(url);

tr	= neurojobs.parse.extract(node,'odd|even','tag','tr');
td	= neurojobs.parse.extract(tr,'Online since','type','text','tag','td');

%title
	cTitle	= neurojobs.parse.extract(td,'b','type','tag','return','text');
%location and date
	cLD	= neurojobs.parse.extract(td,'td','type','tag','return','text');
	sLD	= cellfun(@(ld) regexp(ld,'^. (?<location>.*) \(Online since: (?<date>.*)\)','names'),cLD);
	
	cLocation	= {sLD.location}';
	cDate		= {sLD.date}';
%link
	a		= neurojobs.parse.extract(tr,'Job Details','type','title','tag','a');
	cLink	= neurojobs.parse.extract(a,'a','type','tag','return','href');

nResult	= numel(cTitle);

s	= repmat(neurojobs.result.blank,[nResult 1]);

for kR=1:nResult
	s(kR).date		= FormatTime(cDate{kR});
	s(kR).title		= cTitle{kR};
	s(kR).location	= cLocation{kR};
	s(kR).url		= sprintf('http://aps.psychologicalscience.org/jobs/%s',cLink{kR});
end
