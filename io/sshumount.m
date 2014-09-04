function sshumount(strDir)
% sshumount
% 
% Description:	unmount a folder mounted with sshmount
% 
% Syntax:	sshumount(strDir)
% 
% In:
%	strDir	- the local folder to unmount
% 
% Updated: 2014-01-20
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%make sure we have the correct commands
	cCommandCheck	= {'fusermount'};
	cellfun(@(cmd) syswhich(cmd,'error',true), cCommandCheck, 'uni', false);

%unmount!
	strCommand	= sprintf('fusermount -u %s',strDir);
	
	[ec,out]	= RunBashScript(strCommand,'silent',true);

%error?
	if ec
		error(['unmount was unsuccessful (' StringTrim(out) ')']);
	end
