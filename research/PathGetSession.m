function strSession = PathGetSession(strPath)
% PathGetSession
% 
% Description:	determine a session code from a file path
% 
% Syntax:	strSession = PathGetSession(strPath)
% 
% Updated: 2015-03-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent re cMonths

%first look for a ddmmmyyid-type session code
	if isempty(re)
		%treat "o" as "0"
			re	= '[0123Oo][\dOo][A-Za-z]{3}[\dOo]{2}\w{2,3}';
		
		cMonths	= {'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'};
	end
	
	s	= regexp(strPath,re,'match');
	
	if ~isempty(s) && ismember(s{1}(3:5),cMonths)
		strSession	= s{1};
		return;
	end

%now look for a longitudinal directory structure
	strDir	= PathGetDir(strPath);
	cDir	= DirSplit(strDir);
	nDir	= numel(cDir);
	
	if nDir>=2 && ~isempty(regexp(cDir{end-1},'\w{2,3}')) && ~isempty(regexp(cDir{end},'\d+'))
		strSession	= join(cDir(end-1:end),'_');
		return;
	end

%default to dir_file
	strDir	= char(DirSplit(PathGetDir(strPath),'limit',1));
	strFile	= PathGetFilePre(strPath,'favor','nii.gz');
	 
	strBase	= conditional(isempty(strDir),'',sprintf('%s_',strDir));
	
	strSession	= [strBase strFile];
