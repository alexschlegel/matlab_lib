function [bPrepared,sch,nThread] = SchedulerPrepare(nThreadWant,varargin)
% LocalSchedulerPrepare
% 
% Description:	prepare the local scheduler to run a multithreaded job.  destroy
%				another other jobs that are running
% 
% Syntax:	bPrepared = SchedulerPrepare(nThreadWant,[sch]=<local scheduler>,<options>)
% 
% In:
% 	nThreadWant	- the number of threads that the job wants to use
%	[sch]		- a scheduler object
%	<options>:
%		ntask:	([]) the number of tasks that the job will perform
%		origin:	('abs') either 'abs' or 'rel' to specify whether nThread is
%				absolute or relative to the maximum number of threads
% 
% Out:
% 	bPrepared	- true if the local scheduler is ready for the job.  this will
%				  be false if nThread==1 or <ntask>==1.
%	sch			- the scheduler object, or [] if no scheduler is found
%	nThread		- the actual number of threads that the scheduler is set up to
%				  use
% 
% Updated: 2012-11-21
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bPrepared	= false;
sch			= [];
nThread		= 1;

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

%get the number of threads to use
	nMax	= GetNumCores;
	switch lower(opt.origin)
		case 'abs'
		case 'rel'
			nThreadWant	= nMax + nThreadWant;
		otherwise
			error(['"' tostring(opt.origin) '" is not a valid origin.']);
	end
	
	nThreadWant	= max(1,min(nMax,nThreadWant));
	if nThreadWant>opt.ntask
		nThreadWant	= opt.ntask;
	end
%destroy any current jobs in the scheduler
	if ~SchedulerStop(sch)
		return;
	end
%prepare the scheduler
	if nThreadWant>1 && ~isequal(opt.ntask,1)
	%set the maximum number of workers
		while nThreadWant>1 && ~bPrepared
			try
				set(sch,'ClusterSize',nThreadWant);
				
				nThread		= nThreadWant;
				bPrepared	= true;
			catch me
				nThreadWant	= nThreadWant - 1;
			end
		end
	end
