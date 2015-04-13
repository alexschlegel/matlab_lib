function s = GetSize(strPathNII)
% NIfTI.GetSize
% 
% Description:	get the size of a NIfTI data set.  requires FSL.
% 
% Syntax:	s = NIfTI.GetSize(strPathNII)
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent strScript;

if isempty(strScript)
	cScript		=	{
						sprintf('source %s > /dev/null',FSLPathConfig)
						'fslinfo '
					};
	strScript	= join(cScript,10);
end

%call fslinfo
	[ec,str]	= system([strScript strPathNII]);

%parse the result
	res	= regexp(str,'\ndim(?<idx>\d+)[ ]+(?<dim>\d+)','names');
	s	= cellfun(@str2double,{res.dim});
