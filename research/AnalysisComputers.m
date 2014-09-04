function cName	= AnalysisComputers()
% AnalysisComputers
% 
% Description:	get the names of the analysis computers, with the current
%				computer first by default
% 
% Syntax:	cName	= AnalysisComputers()
% 
% Updated: 2014-01-20
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cName	=	{
				'wertheimer'
				'ramonycajal'
				'ebbinghaus'
				'wundt'
				'helmholtz'
				'fechner'
				'gibson'
				'marr'
				'mach'
				'koffka'
				'kohler'
			};

%am i on the list?
	[bMe, kMe]	= ismember(computername, cName);
	
	if bMe
		cName	= [cName{kMe}; cName(1:kMe-1); cName(kMe+1:end)];
	end
