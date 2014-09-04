function strPath = PromptFilePut(varargin)
% PromptFilePut
% 
% Description:	prompts the user for a file if strPath isn't valid
% 
% Syntax:	strPath = PromptFilePut([strPath],[cExt]={'*.*'},...
%							  [strPrompt]='Choose a File to Save',...
%							  [cStrExt]='',[startPath]=pwd);
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
% Examples: strPath	= PromptFilePut(strPath);
%			strPath = PromptFilePut(strPath,{'*.jpg;*.bmp','*.*'},...
%					  'Choose an Image File to Save',...
%					  {'Image Files','All Files'});
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strPath,cExt,strPrompt,cStrExt,startPath]	= ParseArgs(varargin,'',{},'Choose a File to Save',{},'');

bDoCD	= numel(startPath)~=0;

if isempty(strPath)
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
	[strFile,strPath]	= uiputfile(cExtPrompt,strPrompt);
	if bDoCD
		cd(curPath);
	end
	
	if strFile~=0
		strPath	= [strPath strFile];
	else
		strPath	= [];
	end
end
