function [b,nThread,pool] = MATLABPoolOpen(nThread,varargin)
% MATLABPoolOpen
% 
% Description:	open a matlab pool for parallel processing
% 
% Syntax:	[b,nThread,pool] = MATLABPoolOpen(nThread,<options>)
% 
% In:
% 	nThread	- the number of threads to use
%	<options>:
%		ntask:			([]) the number of tasks that the pool will perform. if
%						1, then the pool won't be opened.
%		distributed:	(<auto>) true to use the distributed computing engine
%		hosts:			([]) a cell of hosts to use for distributed computing
%		workers:		([]) an array the same size as <hosts> specifying the
%						number of threads to use on each host. NaNs specify that
%						the number of threads on that host should be chosen
%						automatically.
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	b		- true if the pool was successfully opened or the pool was already
%			  open
%	nThread	- the number of threads in the pool
%	pool	- a struct of info about the pool
% 
% Updated: 2014-03-28
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'ntask'			, []	, ...
		'distributed'	, []	, ...
		'hosts'			, []	, ...
		'workers'		, []	, ...
		'silent'		, false	  ...
		);

%initialize the outputs
	b		= false;
	pool	= struct('cluster',[],'opened',false);

%should we use the distributed computing engine?
	nCore			= GetNumCores;
	opt.distributed	= unless(opt.distributed,nThread>nCore);

%how many cores do we actually need?
	if ~isempty(opt.ntask)
		nThread	= min(nThread,opt.ntask);
	end

if nThread>1
	%get the cluster object
		if opt.distributed
		%TseCluster!
			try
				pool.cluster	= TseCluster(nThread,opt.hosts,opt.workers,...
									'silent'	, opt.silent	  ...
									);
				
				pool.parcluster	= pool.cluster.cluster;
				
				bClusterOpened	= pool.cluster.opened;
			catch me
				return;
			end
		else
		%local scheduler
			[pool.cluster,pool.parcluster]	= deal(parcluster);
			
			%is it the right size?
				nWorkers		= get(pool.cluster,'NumWorkers');
				bClusterOpened	= nWorkers~=nThread;
				
				if bClusterOpened
				%set the new cluster size
					set(pool.cluster,'NumWorkers',nThread)
				end
		end
	
	%close the current pool if we need to
		bClosePool	= bClusterOpened || matlabpool('size')~=nThread;
		
		if bClosePool
			if opt.silent
				evalc('matlabpool close force');
			else
				matlabpool('close','force');
			end
		end
	
	%open the pool if we need to
		pool.opened	= matlabpool('size')~=nThread;
		
		if pool.opened
			try
				if opt.silent
					evalc('matlabpool(pool.parcluster);');
				else
					matlabpool(pool.parcluster);
				end
			catch me
				return;
			end
		end
	
	nThread	= matlabpool('size');
end

%success!
	b	= true;
