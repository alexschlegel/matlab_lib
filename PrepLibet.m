% PrepLibet
% 
% Description:	sets up a free will work session
% 
% Updated:	2010-07-16
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%constants
global C;

%directories
global strDirBase;
global strDirCode;
	if ispc
		switch getenv('COMPUTERNAME')
			case 'WHEATLEYEEG'
				strDirRoot	= 'D:\studies';
			otherwise
				strDirRoot	= 'C:\studies';
		end
	else
		if isdir('/home/alex/studies/libet')
			strDirRoot	= '/home/alex/studies';
		elseif isdir('/home/tselab/studies/libet')
			strDirRoot	= '/home/tselab/studies';
		else
			strDirRoot = '/mnt/tsestudies/ebbinghaus/';
		end
	end
	
	strDirBase	= DirAppend(strDirRoot,'libet');
	strDirCode	= DirAppend(strDirBase,'code');
	%add the matlab paths (except the directory of old matlab files)
		cDirAdd	= [strDirCode; FindDirectories(strDirCode,'_old','negate',true)];
		addpath(cDirAdd{:});
		clear cDirAdd;
	
	cd(strDirBase);
	
cleanup('default')

status('Welcome Alex');
