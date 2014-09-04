function d = Load(ds)
% Data.DataSet.Load
% 
% Description:	load data from a data set (assumes data is updated)
% 
% Syntax:	d = ds.Load
% 
% Out:
% 	d	- the data
% 
% Updated: 2013-03-09
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
status(['loading parsed data for ' ds.name]);

strPathData	= ds.data_path;

if FileExists(strPathData)
	d	= load(ds.data_path);
else
	d	= struct;
end
