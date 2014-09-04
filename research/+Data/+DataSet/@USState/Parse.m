function Parse(ds)
% Data.DataSet.USState.Parse
% 
% Description:	parse us state data
% 
% Syntax:	ds.Parse
% 
% Updated: 2013-03-10
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
Parse@Data.DataSet(ds);

strPathRaw	= PathUnsplit(ds.data_dir,'raw','html');

str	= fget(strPathRaw);
str	= regexprep(str,'\n|\r','');
str	= regexprep(str,'<br>','');
str	= regexprep(str,'(\s)\s+','$1');
str	= regexprep(str,'<o[^>]*>','');
str	= regexprep(str,'</o[^>]*>','');

kStart	= strfind(str,'FIPS State Codes for the States and the District of Columbia');
kEnd	= kStart-1+strfind(str(kStart:end),'</table>');
kEnd	= kEnd(1);

str	= str(kStart:kEnd);

s	= regexp(str,'<td[^>]+>\s*<p[^>]+>(?<name>[^<]+)</p>\s*</td>\s*<td[^>]+>\s*<p[^>]+>(?<fips>[^<]+)</p>\s*</td>\s*<td[^>]+>\s*<p[^>]+>(?<abbr>[^<]+)</p>\s*</td>','names');

[d.name,kSort]	= sort({s.name}');
d.abbr			= {s.abbr}';
d.abbr			= d.abbr(kSort);
d.fips			= cellfun(@str2num,{s.fips}');
d.fips			= d.fips(kSort);

ds.Save(d);
