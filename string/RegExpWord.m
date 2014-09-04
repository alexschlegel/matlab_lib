function re = RegExpWord(strWord)
% RegExpWord
% 
% Description:	create a regular expression to match a word in a string
% 
% Syntax:	re = RegExpWord(strWord)
% 
% In:
% 	strWord	- the word
% 
% Out:
% 	re	- the regexp string
% 
% Updated:	2009-05-18
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strWord	= StringForRegExp(strWord);

re	=	[	'(^' strWord '$)|'							...
			'(^' strWord '[^a-zA-Z0-9]+)|'				...
			'([^a-zA-Z0-9]+' strWord '[^a-zA-Z0-9]+)|'	...
			'([^a-zA-Z0-9]+' strWord '$)'				...
		];