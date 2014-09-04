function str = TxtRead(varargin)
% TxtRead
% 
% Description:	reads a string from a text file
% 
% Syntax:	str = TxtRead(strPath)
%
% In:
%	strPath	- the path from which to read
% 
% Out:
%	str	- a cell of strings, one element per line of the text file
%
% Side-effects:	reads str from the file strPath
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strPath	= ParseArgs(varargin,[]);
strPath	= PromptFileGet(strPath);

strRead	= fget(strPath);

kCRLF	= strfind(strRead,[13 10]);
if numel(strRead)>0 && strRead(end)~=10
	kCRLF	= [kCRLF numel(strRead)+1];
end
kCRLF	= [-1 kCRLF];

nLines	= numel(kCRLF) - 1;
str		= cell(1,nLines);
for k=1:nLines
	str{k}	= strRead(kCRLF(k)+2:kCRLF(k+1)-1);
end
