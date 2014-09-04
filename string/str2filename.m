function str = str2filename(str)
% str2filename
% 
% Description:	convert a string to a valid file name
% 
% Syntax:	fn = str2filename(str)
% 
% Updated:	2010-11-12
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%characters of interest
	chrGood			= [45:46 65:90 97:122 48:57];

%replace non-good characters with underscores
	bBad		= ~ismember(str,chrGood);
	str(bBad)	= '_';
	str			= StringReduceCharacter(str,'_');
	str			= StringTrim(str,'char','_');
