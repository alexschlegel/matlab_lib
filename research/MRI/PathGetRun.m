function r = PathGetRun(strPathFunctional)
% PathGetRun
% 
% Description:	extract the run from a functional data path
% 
% Syntax:	r = PathGetRun(strPathFunctional)
% 
% Updated: 2012-04-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sRun	= regexp(PathGetFilePre(strPathFunctional,'favor','nii.gz'),'^data_(?<run>[0-9A-Za-z]+)','names');

if ~isempty(sRun)
	if isnumstr(sRun.run)
		r	= str2num(sRun.run);
	else
		r	= sRun.run;
	end
else
	r	= 0;
end
