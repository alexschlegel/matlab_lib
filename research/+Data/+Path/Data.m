function strDirData = Data()
% Data.Path.Data
% 
% Description:	get the data directory
% 
% Syntax:	strDirBase = Data.Path.Data()
% 
% Updated: 2013-03-09
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strDirData	= DirAppend(Data.Path.Base,'data');
