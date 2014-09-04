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

dsState	= Data.DataSet.USState;
dState	= dsState.Load;
nState	= numel(dState.abbr);

for kS=1:nState
	url	= ['http://www.itl.nist.gov/fipspubs/co-codes/' lower(dState.abbr{kS}) '.txt'];
	
	strPathData	= PathUnsplit(ds.data_dir,lower(dState.abbr{kS}),'txt');
	
	urlwrite(url,strPathData);
end
