function [s,extra] = naturejobs(query)
% neurojobs.site.naturejobs
% 
% Syntax:	[s,extra] = neurojobs.site.naturejobs(query)
% 
% Updated: 2014-09-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
%url		= ['http://www.nature.com/naturejobs/science/jobs?utf8=%E2%9C%93&q%5B%5D=' query '&order_by=created_on'];
url				= ['http://www.nature.com/naturejobs/science/jobs?job_type%5B%5D=Postdoctoral&job_type%5B%5D=Assistant+Professor&job_type%5B%5D=Faculty+Member+-+multiple%2Fnon-specific&q%5B%5D=' query '&order_by=created_on'];
[node,extra]	= neurojobs.site.fetch(url);

div	= neurojobs.parse.extract(node,'job-details','tag','div');

cTitle	= neurojobs.parse.extract(div,'a','type','tag','return','text');
cLink	= neurojobs.parse.extract(div,'a','type','tag','return','href');
cPlace	= neurojobs.parse.extract(div,'locale','tag','li','return','text');
cUniv	= neurojobs.parse.extract(div,'employer','tag','li','return','text');
cDate	= neurojobs.parse.extract(div,'when','tag','li','return','text');

nResult	= numel(cTitle);

s	= repmat(neurojobs.result.blank,[nResult 1]);

for kR=1:nResult
	s(kR).date		= FormatTime(cDate{kR});
	s(kR).title		= cTitle{kR};
	s(kR).location	= [cUniv{kR} ', ' cPlace{kR}];
	s(kR).url		= sprintf('http://www.nature.com%s',cLink{kR});
end
