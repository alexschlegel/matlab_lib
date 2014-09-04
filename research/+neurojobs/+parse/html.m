function node = html(str)
% neurojobs.parse.html
% 
% Description:	Use Jsoup to parse HTML
% 
% Syntax:	node = neurojobs.parse.html(str)
% 
% Updated: 2014-08-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strPathJsoup	= neurojobs.path('jsoup');

if ~any(strcmp(javaclasspath,strPathJsoup))
	javaaddpath(strPathJsoup);
end

node	= org.jsoup.Jsoup.parse(str);
