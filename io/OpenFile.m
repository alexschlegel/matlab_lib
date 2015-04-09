function OpenFile(cFile,strProgram)
% OpenFile
% 
% Description:	open a file with its default program
% 
% Syntax:	OpenFile(cFile,strProgram)
% 
% In:
% 	cFile		- a file path or cell of file paths
%	strProgram	- the program to use to open the files
% 
% Updated:	2011-03-01
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
cFile	= ForceCell(cFile);
nFile	= numel(cFile);

for k=1:nFile
	system(sprintf('%s %s&',strProgram,cFile{k}));
end

