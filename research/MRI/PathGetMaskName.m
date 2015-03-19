function strName = PathGetMaskName(strPathMask)
% PathGetMaskName
% 
% Description:	extract the name of a mask from a mask path
% 
% Syntax:	strName = PathGetMaskName(strPathMask)
% 
% Updated: 2015-03-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[strDir,strFile,strExt]	= PathSplit(strPathMask,'favor','nii.gz');
strTest					= PathUnsplit(strDir,strFile);

cRE	=	{
			['(?<mask>[^' filesep '-]+)[-]?[0-9]*\.ica\' filesep '[^' filesep ']*$']
			['mask[-_](?<mask>[^' filesep ']*)$']
			['(?<mask>[^' filesep ']*)$']
		};
nRE	= numel(cRE);

for kR=1:nRE
	s	= regexp(strTest,cRE{kR},'names');
	
	if ~isempty(s)
		strName	= s.mask;
		return;
	end
end

strName	= strFile;
