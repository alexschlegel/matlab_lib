function EditCode(strFunction)
% EditCode
% 
% Description:	open a function in jedit
% 
% Syntax:	EditCode(strFunction)
% 
% Updated: 2011-11-30
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strCommand	= conditional(isunix,'jedit','C:\Programs\Develop\jEdit\jEdit');

OpenFile(which(strFunction),strCommand);
