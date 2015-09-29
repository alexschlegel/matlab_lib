function [doc,extra] = fetch(url)
% neurojobs.fetch
% 
% Description:	retrieve a jobs listing
% 
% Syntax:	[doc,extra] = neurojobs.fetch(url)
% 
% Updated: 2014-09-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
try
	doc	= urlread(url);
catch me
	doc	= neurojobs.urlread2.urlread2(url);
end

doc	= neurojobs.parse.html(doc);

extra	= struct(...
			'url'	, url	  ...
			);
