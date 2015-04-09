function EditCode(strFunction)
% EditCode
% 
% Description:	open a function/file in jedit
% 
% Syntax:	EditCode(strFunction)
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strCommand	= conditional(isunix,'jedit','C:\Programs\Develop\jEdit\jEdit');

if ~FileExists(strFunction)
	strFunction	= which(strFunction);
end

OpenFile(strFunction,sprintf('%s -reuseview',strCommand));
