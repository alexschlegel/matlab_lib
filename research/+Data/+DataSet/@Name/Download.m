function Download(ds)
% Data.DataSet.Name.Download
% 
% Description:	download raw data about names
% 
% Syntax:	ds.Download
% 
% Updated: 2013-06-17
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
Download@Data.DataSet(ds);

strDirMe	= PathGetDir(mfilename('fullpath'));
strPathFrom	= PathUnsplit(strDirMe,'data','dat');

strPathTo	= PathUnsplit(ds.data_dir,'name','dat');

FileCopy(strPathFrom,strPathTo);
