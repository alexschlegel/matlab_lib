function bLoaded = SetName(ifo,strName)
% PTB.Info.SetName
% 
% Description:	set the name of the info struct (determines the output path)
% 
% Syntax:	bLoaded = ifo.SetName(strName)
%
% Out:
%	bLoaded	- true if existing data were loaded
% 
% Updated: 2012-02-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bLoaded	= false;

%get the new file path
	ifo.Set('session','name',strName);
	ifo.parent.File.Set('session','data',[strName '.mat']);
	
	strPath	= ifo.parent.File.Get('session');
%check to see if the info path already exists
	if FileExists(strPath)
		strDefault	= conditional(ifo.parent.Info.Get('experiment','debug')==2,'overwrite','load');
		
		res	= ifo.parent.Prompt.Ask(['Session data for ' strName ' already exist in "' strPath '".  What should we do?'],'choice',{'load','abort','rename','overwrite'},'default',strDefault);
		switch res
			case 'load'
				bLoaded	= true;
				
				ifo.Load;
			case 'abort'
				error('Experiment aborted.');
			case 'rename'
				%get the first non-existent session name variation as the default
					strLetter	= 'A' - 1;
					
					while FileExists(strPath)
						strLetter	= char(strLetter + 1);
						
						ifo.parent.File.Set('session','data',[strName strLetter '.mat']);
						strPath	= ifo.parent.File.Get('session');
					end
				
				bLoaded	= ifo.SetName(ifo.parent.Prompt.Ask('Enter the new session name','default',[strName strLetter]));
				return;
			case 'overwrite'
				delete(strPath);
		end
	end
%save the struct
	strStatus	= ['session info struct saving to: "' strPath '"'];
	ifo.parent.Status.Show(strStatus,'time',false);
	
	ifo.Save;
