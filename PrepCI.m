% PrepCI
% 
% Description:	sets up a constructive imagery work session
% 
% Updated:	2011-11-30
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%constants
global C;

%directories
global strDirBase;
global strDirCode;
	strStudy	= 'constructive_imagery';
	
	if ispc %naraka-win
		[b,strName]	= dos('ECHO %COMPUTERNAME%');
        strName     = StringTrim(strName);
		
        switch lower(strName)
            case 'dbicscannerpc'
                strDirRoot	= 'C:\schlegel\';	%dbic scanner pc
            case 'kohler'
                strDirRoot	= 'D:\studies\';
            otherwise
                strDirRoot	= 'C:\studies\';	%naraka-win
        end
    elseif isdir(DirAppend('/','home','psychophysics','studies',strStudy)) 
    	strDirRoot	= DirAppend('/','home','psychophysics','studies');	%psychophysics
	elseif isdir(DirAppend('/','home','tselab','studies',strStudy))
		strDirRoot	= DirAppend('/','home','tselab','studies');	%wundt
	elseif isdir(DirAppend('/','mnt','tsestudies'))
		if isdir(DirAppend('/','home','alex','studies'))
			strDirRoot	= DirAppend('/','home','alex','studies');	%naraka-ubuntu
		else
			strDirRoot	= DirAppend('/','mnt','tsestudies','wundt');	%other linux
		end
	else
		error('Could not find CI directory.');
	end
	
	strDirBase	= DirAppend(strDirRoot,strStudy);
	strDirCode	= DirAppend(strDirBase,'code');
	
	%add the matlab paths (except the directory of old matlab files)
		cDirAdd	= [strDirCode; FindDirectories(strDirCode,'(\+)|(_old)','negate',true)];
		addpath(cDirAdd{:});
		clear cDirAdd;
	
	cd(strDirBase);
	
cleanup('default')

status('Good to go!');
