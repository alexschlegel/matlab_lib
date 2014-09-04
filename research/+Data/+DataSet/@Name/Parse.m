function Parse(ds)
% Data.DataSet.Name.Parse
% 
% Description:	parse name data
% 
% Syntax:	ds.Parse
% 
% Updated: 2013-06-17
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
Parse@Data.DataSet(ds);

strPathRaw	= PathUnsplit(ds.data_dir,'name','dat');
strRaw		= fget(strPathRaw);

cField	= {'name','b','c','d','e','weight'};
dAll	= table2struct(strRaw,...
			'fields'	, cField	, ...
			'delim'		, 'csv'		  ...
			);

d	= struct(...
		'name'		, {dAll.name}	, ...
		'weight'	, dAll.weight	  ...
		);

ds.Save(d);
