% PrepLA
% 
% Description:	sets up a language acquisition work session
% 
% Updated:	2011-03-06
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%constants
global C;

%directories
global strDirBase;
global strDirCode;
	if ispc %naraka-win
		strDirRoot	= 'C:\studies\';
		strDirBase	= DirAppend(strDirRoot,'language_acquisition');
		strDirCode	= DirAppend('c:','studies','language_acquisition','code');
	elseif isdir('/home/tselab/studies/language_acquisition') %tsebeast / tse64linux
		strDirRoot	= '/home/tselab/studies/';
		strDirBase	= DirAppend(strDirRoot,'language_acquisition');
		strDirCode	= DirAppend(strDirBase,'code');
	elseif isdir('/home/alex/studies/') %naraka-ubuntu
		strDirRoot	= '/home/alex/studies/';%'/mnt/tsebeast/';
		strDirBase	= DirAppend(strDirRoot,'language_acquisition');
		strDirCode	= DirAppend('~','studies','language_acquisition','code');
	elseif isdir('/mnt/tsestudies/ramonycajal') %analysis computer
		strDirRoot	= '/mnt/tsestudies/ramonycajal';
		strDirBase	= DirAppend(strDirRoot,'language_acquisition');
		strDirCode	= DirAppend(strDirBase,'code');
	else
		error('Could not find LA directory.');
	end
	
	%add the matlab paths (except the directory of old matlab files)
		cDirAdd	= [strDirCode; FindDirectories(strDirCode,'_old','negate',true)];
		addpath(cDirAdd{:});
		clear cDirAdd;
	
	cd(strDirBase);
	
cleanup('default')

status('Welcome Alex');
