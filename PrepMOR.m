% PrepMOR
% 
% Description:	sets up a MO Rotation work session
% 
% Updated:	2012-06-12
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%constants
global C;

%directories
global strDirBase;
global strDirCode;
	strStudy	= 'mo_rotation';
	
	if ispc %naraka-win
		[b,strName]	= dos('ECHO %COMPUTERNAME%');
        strName     = StringTrim(strName);
		
        switch lower(strName)
            case 'dbicscannerpc'
                strDirRoot	= 'C:\schlegel\';	%dbic scanner pc
            otherwise
                strDirRoot	= 'C:\studies\';	%naraka-win
        end
    elseif isdir(DirAppend('/','home','psychophysics','studies',strStudy)) 
    	strDirRoot	= DirAppend('/','home','psychophysics','studies');	%psychophysics
	elseif isdir(DirAppend('/','home','tselab','studies',strStudy))
		strDirRoot	= DirAppend('/','home','tselab','studies');	%helmholtz
	elseif isdir(DirAppend('/','mnt','tsestudies'))
		if isdir(DirAppend('/','home','alex','studies'))
			strDirRoot	= DirAppend('/','home','alex','studies');	%naraka-ubuntu
		else
			strDirRoot	= DirAppend('/','mnt','tsestudies','helmholtz');	%other linux
		end
	else
		error('Could not find MOR directory.');
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
