function strPath = PromptFileGet(varargin)
% PromptFileGet
% 
% Description:	prompts the user for a file if strPath isn't valid
% 
% Syntax:	strPath = PromptFileGet([strPath],[cExt]={'*.*'},...
%									[strPrompt]='Choose a File',[cStrExt]='',...
%									[startPath]=pwd);
%
% In:
%	[strPath]	- a file path
%	[cExt]		- an extension identifier or a cell of valid extension
%				  identifiers
%	[strPrompt]	- the prompt to display
%	[cStrExt]	- the string to display in the extension dropdown list
%				  (before the extension list),
%				  or a cell of strings
%	[startPath]	- the directory to start in
% 
% Out:
%	strPath		- either strPath or the file path specified by the user
%
% Examples: strPath	= PromptFileGet(strPath);
%			strPath = PromptFileGet(strPath,{'*.jpg;*.bmp','*.*'},...
%					  'Choose an Image File',{'Image Files','All Files'});
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strPath,cExt,strPrompt,cStrExt,startPath]	= ParseArgs(varargin,'',{},'Choose a File',{},'');

bDoCD	= numel(startPath)~=0;

if ~exist(strPath,'file')
	if ~iscell(cExt) 	cExt	= {cExt};		end
	if ~iscell(cStrExt)	cStrExt	= {cStrExt};	end
	
	
	nExt	= numel(cExt);
	if nExt==0
		nExt	= 1;
		cExt	= {'*.*'};
		cStrExt	= {'All Files'};
	else
		if nExt>numel(cStrExt)
			[cStrExt{numel(cStrExt)+1:nExt}]	= deal('');
		end
	end
	
	cExtPrompt	= cell(nExt,2);
	for k=1:nExt
		cExtPrompt{k,1}	= cExt{k};
		cExtPrompt{k,2}	= [cStrExt{k} '(' strrep(cExt{k},';',', ') ')'];
	end
	
	if bDoCD
		curPath	= pwd;
		cd(startPath);
	end
	[strFile,strPath]	= uigetfile(cExtPrompt,strPrompt,'MultiSelect','on');
	if bDoCD
		cd(curPath);
	end
	
	if iscell(strFile)
		nFile	= numel(strFile);
		for k=1:nFile
			strFile{k}	= [strPath strFile{k}];
		end
		strPath	= strFile;
	else
		if strFile~=0
			strPath	= [strPath strFile];
		else
			strPath	= [];
		end
	end
end
