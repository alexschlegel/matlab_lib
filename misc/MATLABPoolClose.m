function bClosed = MATLABPoolClose(varargin)
% MATLABPoolClose
% 
% Description:	close a matlab pool and destroy all jobs
% 
% Syntax:	bClosed = MATLABPoolClose([pool],<options>)
% 
% In:
%	[pool]	- the struct returned by MATLABPoolOpen
%	<options>:
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	bClosed	- true if the pool was successfully closed or if it wasn't open to
%			  begin with
% 
% Updated: 2014-03-28
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[pool,opt]	= ParseArgs(varargin,[],...
				'silent'	, false	  ...
				);

%initialize the output
	bClosed	= false;

%get the pool info
	if isempty(pool)
		pool	= struct('parcluster',parcluster);
	end

%close the pool
	bPoolOpen	= matlabpool('size')~=0;
	
	if bPoolOpen
		try
			if opt.silent
				evalc('matlabpool close force');
			else
				matlabpool('close','force');
			end
			
			bClosed	= true;
		catch me
		end
	end
	
%destroy all jobs on the cluster
	try
		jobs	= get(pool.parcluster,'Jobs');
	
		if numel(jobs)>0
			destroy(jobs);
		end
	catch me
	end

%close the cluster
	switch class(pool.parcluster)
		case 'TseCluster'
			pool.cluster.Close;
		otherwise
		%nothing to do
	end
