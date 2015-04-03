function strName = PathGetDataName(strPathData)
% PathGetDataName
% 
% Description:	construct a name to identify a data path
% 
% Syntax:	strName = PathGetDataName(strPathData)
%
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[strDir,strFile,strExt]	= PathSplit(strPathData,'favor','nii.gz');
nFile					= numel(strFile);
cDir					= DirSplit(strDir);
nDir					= numel(cDir);

if numel(cDir)>0 && strcmp(cDir{1},filesep)
	cDir	= cDir(2:end);
	nDir	= nDir - 1;
end

cKey	= {'functional','structural','diffusion','mask'};
nKey	= numel(cKey);
cPrefix	= [cKey 'data'];
nPrefix	= numel(cPrefix);

%look for a session directory
	strSession	= PathGetSession(strPathData);
	
	if ~isempty(strSession)
		kDir	= find(strcmp(cDir,strSession),1,'last');
		if ~isempty(kDir)
			if kDir>1 && ismember(cDir(kDir-1),cKey)
				kDir	= kDir - 1;
			end
			
			cDir	= cDir(kDir:end);
		end
	end

%remove unnecessary information from the file name
	for kP=1:nPrefix
		strPrefix	= cPrefix{kP};
		nPrefix		= numel(strPrefix);
		if nFile>nPrefix && strcmp(strFile(1:nPrefix+1),sprintf('%s_',strPrefix))
			strFile	= strFile(nPrefix+2:end);
		end
	end

strName	= join([cDir; strFile],'_');
