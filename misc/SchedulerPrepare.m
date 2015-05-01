function [bPrepared,sch,nCore] = SchedulerPrepare(nCoreWant,varargin)
% LocalSchedulerPrepare
% 
% Description:	prepare the local scheduler to run a multicore job. destroy
%				another other jobs that are running.
% 
% Syntax:	bPrepared = SchedulerPrepare(nCoreWant,[sch]=<local scheduler>,<options>)
% 
% In:
% 	nCoreWant	- the number of cores that the job wants to use
%	[sch]		- a scheduler object
%	<options>:
%		ntask:	([]) the number of tasks that the job will perform
%		origin:	('abs') either 'abs' or 'rel' to specify whether nCore is
%				absolute or relative to the maximum number of cores
% 
% Out:
% 	bPrepared	- true if the local scheduler is ready for the job.  this will
%				  be false if nCore==1 or <ntask>==1.
%	sch			- the scheduler object, or [] if no scheduler is found
%	nCore		- the actual number of cores that the scheduler is set up to
%				  use
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bPrepared	= false;
sch			= [];
nCore		= 1;

[sch,opt]	= ParseArgs(varargin,[],...
				'ntask'		, []	, ...
				'origin'	, 'abs'	  ...
				);

if isempty(sch)
	sch	= GetSchedulerLocal;
	
	if isempty(sch)
		return;
	end
end

%get the number of cores to use
	nMax	= GetNumCores;
	switch lower(opt.origin)
		case 'abs'
		case 'rel'
			nCoreWant	= nMax + nCoreWant;
		otherwise
			error(['"' tostring(opt.origin) '" is not a valid origin.']);
	end
	
	nCoreWant	= max(1,min(nMax,nCoreWant));
	if nCoreWant>opt.ntask
		nCoreWant	= opt.ntask;
	end
%destroy any current jobs in the scheduler
	if ~SchedulerStop(sch)
		return;
	end
%prepare the scheduler
	if nCoreWant>1 && ~isequal(opt.ntask,1)
	%set the maximum number of workers
		while nCoreWant>1 && ~bPrepared
			try
				set(sch,'ClusterSize',nCoreWant);
				
				nCore		= nCoreWant;
				bPrepared	= true;
			catch me
				nCoreWant	= nCoreWant - 1;
			end
		end
	end
