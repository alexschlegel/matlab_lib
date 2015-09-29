function [s,extra] = higheredjobs(query)
% neurojobs.site.higheredjobs
% 
% Syntax:	[s,extra] = neurojobs.site.higheredjobs(query)
% 
% Updated: 2014-09-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
url				= ['https://www.higheredjobs.com/search/advanced_action.cfm?Remote=1,2&Keyword=' query '&PosType=1&InstType=1&JobCat=91,97,100,108&Region=0&SubRegions=&Metros=&OnlyTitle=0&SortBy=1&NumJobs=100'];
[node,extra]	= neurojobs.site.fetch(url);

%div		= neurojobs.parse.extract(node,'jobResults','type','attr','attr','id');
div		= neurojobs.parse.extract(node,'js-results','type','attr','attr','id');

%divJob	= neurojobs.parse.extract(div,'jobTitle','tag','div');
divJob	= neurojobs.parse.extract(div,'row record','tag','div');

	cTitle		= neurojobs.parse.extract(divJob,'a','type','tag','return','text');
	cLink		= neurojobs.parse.extract(divJob,'a','type','tag','return','href');
	%cDetails	= neurojobs.parse.extract(div,'jobDetails','tag','div','return','text');
	cDetails	= neurojobs.parse.extract(div,'col-sm-7','tag','div','return','elements');
	cDetails2	= neurojobs.parse.extract(divJob,'col-sm-5','tag','div','return','text');
	
	%cUniv		= neurojobs.parse.extract(div,'instName','tag','div','return','text');
	%cPlace		= neurojobs.parse.extract(div,'jobLocation','tag','div','return','text');
	
	nResult	= numel(cTitle);
	
	s	= repmat(neurojobs.result.blank,[nResult 1]);

for kR=1:nResult
	strDetails	= char(cDetails.get(kR-1));
	re			= regexp(strDetails,'<br />(?<univ>.*)\n\s*<br />(?<place>.*)\n','names');
	
	
	s(kR).location	= [strtrim(re.univ) ', ' strtrim(re.place)];
	s(kR).title		= cTitle{kR};
	s(kR).url		= sprintf('http://www.higheredjobs.com/search/%s',cLink{kR});
	
	s(kR).date		= FormatTime(getfield(regexp(cDetails2{kR},'Posted (?<date>\d+/\d+/\d+)','names'),'date'));
	
end
