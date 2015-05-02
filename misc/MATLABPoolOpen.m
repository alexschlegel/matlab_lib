function [b,nCore,pool] = MATLABPoolOpen(nCore,varargin)
% MATLABPoolOpen
% 
% Description:	open a matlab pool for parallel processing
% 
% Syntax:	[b,nCore,pool] = MATLABPoolOpen(nCore,<options>)
% 
% In:
% 	nCore	- the number of processor cores to use
%	<options>:
%		ntask:			([]) the number of tasks that the pool will perform. if
%						1, then the pool won't be opened.
%		distributed:	(<auto>) true to use the distributed computing engine
%		hosts:			([]) a cell of hosts to use for distributed computing
%		workers:		([]) an array the same size as <hosts> specifying the
%						number of cores to use on each host. NaNs specify that
%						the number of cores on that host should be chosen
%						automatically.
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	b		- true if the pool was successfully opened or the pool was already
%			  open
%	nCore	- the number of cores in the pool
%	pool	- a struct of info about the pool
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
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
	nCoreMax		= GetNumCores;
	opt.distributed	= unless(opt.distributed,nCore>nCoreMax);

%how many cores do we actually need?
	if ~isempty(opt.ntask)
		nCore	= min(nCore,opt.ntask);
	end

if nCore>1
	%get the cluster object
		if opt.distributed
		%TseCluster!
			try
				pool.cluster	= TseCluster(nCore,opt.hosts,opt.workers,...
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
				bClusterOpened	= nWorkers~=nCore;
				
				if bClusterOpened
				%set the new cluster size
					set(pool.cluster,'NumWorkers',nCore);
				end
		end
	
	%close the current pool if we need to
		bClosePool	= bClusterOpened || matlabpool('size')~=nCore;
		
		if bClosePool
			if opt.silent
				evalc('matlabpool close force');
			else
				matlabpool('close','force');
			end
		end
	
	%open the pool if we need to
		pool.opened	= matlabpool('size')~=nCore;
		
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
	
	nCore	= matlabpool('size');
end

%success!
	b	= true;
