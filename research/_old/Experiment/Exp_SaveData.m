function sSession = Exp_SaveData(sSession)
% Exp_SaveData
% 
% Description:	save session data
% 
% Syntax:	sSession = Exp_SaveData(sSession)
% 
% Updated: 2010-10-29
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	status('saving data');
	
	if ~sSession.debug
		diary off
		sSession.log	= fget(sSession.param.path_log);
		diary on
		
		save(sSession.param.path_data,'-struct','sSession');
	end
