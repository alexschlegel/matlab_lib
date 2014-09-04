function Download(ds)
% Data.DataSet.USState.Download
% 
% Description:	download raw data about US States
% 
% Syntax:	ds.Download
% 
% Updated: 2013-03-10
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
Download@Data.DataSet(ds);

url	= 'http://www.itl.nist.gov/fipspubs/fip5-2.htm';

strPathData	= PathUnsplit(ds.data_dir,'raw','html');

urlwrite(url,strPathData);
