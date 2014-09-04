function strPath = PromptDir(varargin)
% PromptDir
% 
% Description:	prompts the user for a directory if strPath isn't valid
% 
% Syntax:	strPath = PromptDir([strPath],[strPrompt]='Choose a Directory:',...
%							 [startPath]=pwd);
%
% In:
%	[strPath]	- a directory path
%	[strPrompt]	- the prompt to display
%	[startPath]	- the directory to start in
% 
% Out:
%	strPath		- either strPath or the directory path specified by the user
%
% Examples: strPath	= PromptDir(strPath);
%			strPath = PromptDir(strPath,'Choose the Output Directory:','c:\temp');
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strPath,strPrompt,startPath]	= ParseArgs(varargin,'','Choose a Directory:',pwd);

if ~exist(strPath,'dir')
	strPath	= uigetdir(startPath,strPrompt);
end

if ~isequal(strPath,0)
	strPath	= AddSlash(strPath);
else
	strPath	= [];
end
