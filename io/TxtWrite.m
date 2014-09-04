function TxtWrite(str,varargin)
% TxtWrite
% 
% Description:	saves a string to a text file
% 
% Syntax:	TxtWrite(str,strPath)
%
% In:
%	str		- the string (or cell) to save.  saves each row and cell element
%			  on a new line
%	strPath	- the path to which to save
% 
% Side-effects:	writes str to the file strPath, overwriting if necessary
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strPath	= ParseArgs(varargin,[]);
strPath	= PromptFilePut(strPath);

if exist(strPath,'file') delete(strPath); end

switch class(str)
	case 'cell'
	case 'char'
		str	= cellstr(str);
	otherwise
		str	= cellstr(num2str(str));
end

strWrite	= '';
nLines		= numel(str);
for k=1:nLines
	strWrite	= [strWrite num2str(str{k}) 13 10];
end

fid	= fopen(strPath,'w');
fwrite(fid,strWrite);
fclose(fid);
