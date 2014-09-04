function strPath = path(thing)
% neurojobs.path
% 
% Description:	get the path to something
% 
% Syntax:	strPath = neurojobs.path(thing)
% 
% Updated: 2014-08-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strPathMe	= mfilename('fullpath');
strDirMe	= PathGetDir(strPathMe);

switch lower(thing)
	case 'jsoup'
		strPath	= PathUnsplit(strDirMe,'jsoup-1.7.3','jar');
	otherwise
		error(sprintf('%s is not a valid thing.',thing));
end
