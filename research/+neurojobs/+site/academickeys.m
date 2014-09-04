function [s,extra] = academickeys(query)
% neurojobs.site.academickeys
% 
% Syntax:	[s,extra] = neurojobs.site.academickeys(query)
% 
% Updated: 2014-09-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
url				= ['http://sciences.academickeys.com/seeker_search.php?q=' query '&advanced=&job%5Bctry%5D=&sort=write_datetime'];
[node,extra]	= neurojobs.site.fetch(url);

div			= neurojobs.parse.extract(node,'layout_main','type','attr','attr','id','tag','div');
record		= neurojobs.parse.extract(node,'record','tag','table');
formsmall	= neurojobs.parse.extract(div,'form small','tag','ul');
strong		= neurojobs.parse.extract(record,'strong','type','tag');

cTitle	= neurojobs.parse.extract(strong,'a','type','tag','return','html');
cLink	= neurojobs.parse.extract(strong,'a','type','tag','return','href');

cPlace	= neurojobs.parse.extract(formsmall,'div','type','tag','return','text');

cDate	= neurojobs.parse.extract(formsmall,'li','type','tag','return','text');
cDate	= cDate(3:5:end);

cUniv	= neurojobs.parse.extract(record,'strong','type','tag','return','text');
cUniv	= cUniv(2:2:end);

nResult	= numel(cTitle);

s	= repmat(neurojobs.result.blank,[nResult 1]);

for kR=1:nResult
	s(kR).date		= FormatTime(cDate{kR});
	s(kR).title		= regexprep(cTitle{kR},'<[^>]>','');
	s(kR).location	= [cUniv{kR} ', ' cPlace{kR}];
	s(kR).url		= cLink{kR};
end
