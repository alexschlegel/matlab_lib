function varargout = MultiTask(f,cIn,varargin)
% MultiTask
% 
% Description:	perform a set of tasks in parallel
% 
% Syntax:	[cOut1,...,cOutN] = MultiTask(f,cIn,<options>)
% 
% In:
% 	f	- a function handle or cell of function handles of the tasks to call.
%		  each function must return the number of specified outputs.
%	cIn	- a cell of input arguments. each entry of cIn is either an nTask-length
%		  cell, in which case each element of the cell will be used as an input
%		  argument for a separate call to f, or an array that will be passed as
%		  the corresponding input argument to all tasks.
%	<options>:
%		description:		('running tasks') a description of the job
%		uniformoutput:		(false) true if outputs are all scalar (like
%							cellfun)
%		cores:				(<num cores - 1>) number of tasks to execute
%							simultaneously
%		distributed:		(<auto>) true to use the distributed computing
%							engine
%		hosts:				(<auto>) the hosts to use (see MATLABPoolOpen)
%		workers:			(<auto>) the numbers of workers to use on each host
%							(see MATLABPoolOpen)
%		catch:				(false) true to catch errors without killing the
%							entire job
%		interface:			('inbound') the interface to use for manager/worker
%							communication (see getip)
%		base_port:			(30000) the base port to use for the manager/worker
%							communicators
%		debug:				('warn') the debug level (either 'error', 'warn',
%							'info', 'most', or 'all')
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	cOutK	- a cell or array of the Kth set of outputs
% 
% Updated: 2016-01-15
% Copyright 2016 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input
	opt	= ParseArgs(varargin,...
			'description'			, 'running tasks'	, ...
			'uniformoutput'			, false				, ...
			'cores'					, []				, ...
			'distributed'			, []				, ...
			'hosts'					, []				, ...
			'workers'				, []				, ...
			'catch'					, false				, ...
			'interface'				, 'inbound'			, ...
			'base_port'				, 30000				, ...
			'debug'					, 'warn'			, ...
			'silent'				, false				  ...
			);
	
	if isempty(opt.cores)
		opt.cores	= GetNumCores-1;
	end

%start the log
	L	= Log(...
			'level'		, opt.debug		, ...
			'ms'		, true			, ...
			'silent'	, opt.silent	  ...
			);

%prepare the inputs and outputs
	[f,cIn{:}]	= ForceCell(f,cIn{:});
	[f,cIn{:}]	= FillSingletonArrays(f,cIn{:});
	
	bEmptyInput	= any(cellfun(@numel,cIn)==0);
	nTask		= numel(f);
	sTask		= size(f);
	nIn			= numel(cIn);
	nOut		= nargout;
	
	if bEmptyInput || nTask==0 || nIn==0
		[varargout{1:nOut}]	= deal([]);
		return;
	end
	
	%make one input cell for each task
		cIn	= cellfun(@(varargin) varargin,cIn{:},'uni',false);

%prepare the progress bar
	strLabel	= sprintf('%s (%d core%s)',opt.description,opt.cores,plural(opt.cores));
	sProgress	= progress('action','init','total',nTask,'label',strLabel,'silent',opt.silent);
	pName		= sProgress.name;

%execute the jobs
	%pass along some info to the subfunctions
		opt.log				= L;
		opt.progress		= pName;
		opt.nout			= nOut;
	
	if opt.cores>1
	%use the distributed computing toolbox
		cOut	= MultiTaskParallel(f,cIn,opt);
		
		%close the progress bar
			progress('action','end','name',pName);
	else
	%just a regular old for loop
		cOut	= MultiTaskSerial(f,cIn,opt);
	end

%process the outputs
	%restructure the outputs
		cOut	= cellfun(@(varargin) reshape(varargin,sTask),cOut{:},'uni',false);
	
	%convert to numerical arrays
		if opt.uniformoutput
			%check for non-scalar outputs
				bScalar		= cellfun(@(v) cellfun(@isscalar,v),cOut,'uni',false);
				bAllScalar	= all(cellfun(@(x) all(x(:)),bScalar));
			%convert non-scalars to NaNs
				if ~bAllScalar
					L.Print('non-scalar values detected in output. converting to NaN.','warn');
					
					cOut	= cellfun(@(b,v) conditional(b,v,NaN),bScalar,cOut,'uni',false);
				end
			%convert cells to numerical arrays
				cOut	= cellfun(@cell2mat,cOut,'uni',false);
		end
	
	varargout	= cOut;

end

%------------------------------------------------------------------------------%
function cOut = MultiTaskParallel(f,cIn,param)
	nTask	= numel(f);
	nOut	= param.nout;
	
	%turn off some warnings
		warning('off','parallel:cluster:CannotSaveCorrectly');
		warning('off','parallel:cluster:CannotLoadCorrectly');
	
	%some constants
		param.msg.FINISHED_TASK	= 1;
		param.msg.ERROR			= 2;
		param.msg.CONTINUE		= 3;
		param.msg.ABORT			= 4;
	
	%open the pool
		[nPool,pool]	= OpenPool;
		
		if nPool==1
			ClosePool(pool);
			cOut	= MultiTaskSerial(f,cIn,param);
			return;
		end
	
	%initialize some variables for the manager
		err				= [];
		hTimerProgress	= [];
		nTaskFinished	= zeros(nPool,1);
		bProgressEnd	= false;
	
	%initialize some variables for the workers
		bContinue	= repmat({struct},[nPool 1]);
	
	%get the tcp/ip ports to use
		param.port	= freeport(param.base_port,nPool);
	
	%initialize the client communicators
		param.ipManager	= getip('interface', param.interface);
		
		cClient	= arrayfun(@InitializeClient,(1:nPool)','uni',false);
	
	%initialize the cell for task outputs
		cOut	= cell(nTask,1);
		
	%fork a process to manage the workers
		hManager		= fork(@ManageWorkers,{nPool},'delay',1);
	
	%execute!
		ManagerStatus('let the workers be!','info');
		
		try
			parfor kT=1:nTask
				%make sure we have a communicator open with the manager
					id	= GetWorkerID;
					
					if ~cClient{id}.connected
						WorkerStatus(id,'i am!','info',param);
						
						cClient{id}.Connect;
					end
					
				%execute the task
					if cClient{id}.flag
						try
							cOut{kT}			= cell(nOut,1);
							[cOut{kT}{1:nOut}]	= f{kT}(cIn{kT}{:});
						catch me
							WorkerError(id,cClient{id},kT,me,param);
						end
					
					%let the manager know we finished the task
						bContinue	= FinishedTask(id,cClient{id},kT,param);
						
						cClient{id}.SetFlag(bContinue);
					end
			end
		catch me
			ManagerError(me.message);
		end
	
	%close the clients
		cellfun(@delete,cClient);
	
	%stop the manager
		StopManager(hManager);
	
	%close the pool
		ClosePool(pool);
	
	%did an error occur?
		assert(isempty(err),'an error occurred: %s',err);
	
	%--------------------------------------------------------------------------%
	function [nPool,pool] = OpenPool
		bSilent	= param.silent || ~param.log.TestLevel('info');
		
		[b,nPool,pool]	= MATLABPoolOpen(param.cores,...
							'ntask'			, nTask				, ...
							'distributed'	, param.distributed	, ...
							'hosts'			, param.hosts		, ...
							'workers'		, param.workers		, ...
							'silent'		, bSilent			  ...
							);
		
		assert(b,'could not open the MATLAB pool.');
	end
	%--------------------------------------------------------------------------%
	function ClosePool(pool)
		bClose	= unless(GetFieldPath(pool,'opened'),false);
		
		if bClose && ~MATLABPoolClose(pool,'silent',param.silent)
			ManagerStatus('could not close the MATLAB pool.','warn');
		end
	end
	%--------------------------------------------------------------------------%
	function client = InitializeClient(kWorker)
	%open a client communicator
		strIP	= sprintf('%s:%d',param.ipManager,param.port(kWorker));
		
		WorkerStatus(kWorker,sprintf('will use connection %s to the manager',strIP),'info',param);
		
		client		= CommunicatorLite(param.port(kWorker),param.ipManager);
		client.flag	= true;
	end
	%--------------------------------------------------------------------------%
	function servers = ManageWorkers(nWorker)
	%keep track of and assign tasks to the worker processes
		%start a process to update the progress bar
			hTimerProgress	= timer(...
								'TimerFcn'		, @UpdateProgress			, ...
								'ErrorFcn'		, @(tmr,evt) UserAbort()	, ...
								'Period'		, 0.25						, ...
								'ExecutionMode'	, 'fixedSpacing'			, ...
								'StartDelay'	, 1							  ...
								);
			start(hTimerProgress);
		
		ManagerStatus('opening connections to the workers','info');
		
		%start a communicator for each worker
			servers	= cell(nWorker,1);
			
			for kW=1:nWorker
				servers{kW}	= CommunicatorLite(param.port(kW),...
								'handler'	, @(com,msg) ProcessWorker(com,msg,kW)	 ...
								);
				
				ManagerStatus(sprintf('listening for worker %d on port %d',kW,param.port(kW)),'most');
				
				servers{kW}.Connect;
				
				ManagerStatus(sprintf('worker %d found!',kW),'most');
			end
		
		ManagerStatus('all worker connections opened','info');
	end
	%--------------------------------------------------------------------------%
	function StopManager(hManager)
	%shutdown the manager
		%stop the progress bar timer
			if ~isempty(hTimerProgress)
				stop(hTimerProgress);
				delete(hTimerProgress);
			end
		
		%get the communicators opened by the forked Manager
			servers	= forkOutput(hManager);
		
		%close them
			if ~isempty(servers)
				ManagerStatus('closing worker connections','info');
				
				cellfun(@delete,servers);
				
				ManagerStatus('all worker connections closed','info');
			end
	end
	%--------------------------------------------------------------------------%
	function ProcessWorker(server,msg,kWorker)
	%process a message from the worker
		str	= sprintf('processing message %s from worker %d',tostring(msg.message),kWorker);
		ManagerStatus(str,'all');
		
		%what to do?
			reply	= conditional(isempty(err),param.msg.CONTINUE,param.msg.ABORT);
			
			switch msg.message
				case param.msg.FINISHED_TASK
					nTaskFinished(kWorker)	= nTaskFinished(kWorker) + 1;
				case 'error'
				%worker experienced an error
					ManagerError(sprintf('An error occured on worker %d',kWorker));
			end
		%send the reply
			ManagerStatus(sprintf('sending reply %s to worker %d',tostring(reply),kWorker),'all');
			
			server.Reply(msg,reply);
	end
	%--------------------------------------------------------------------------%
	function ManagerStatus(strStatus, level, varargin)
	%the manager uses this to display a log message
		param.log.Print(sprintf('manager: %s',strStatus),level,varargin{:});
	end
	%--------------------------------------------------------------------------%
	function ManagerError(strError)
	%the manager uses this to process an error
		if ~param.catch
			%close this here because an error will be raised shortly
				progress('action','end','name',param.progress);
			
			if isempty(err)
				err	= strError;
			end
			
			ManagerStatus(sprintf('aborting the job because an error occurred: %s',strError),'error');
		end
	end
	%--------------------------------------------------------------------------%
	function UpdateProgress(tmr,evt)
	%update the progress bar
		try
			n	= sum(nTaskFinished);
			
			if ~bProgressEnd
				progress('current',n,'name',param.progress);
			end
			
			if nTaskFinished==nTask
				bProgressEnd	= true;
			end
		catch me
			UserAbort();
			stop(tmr);
		end
	end
	%--------------------------------------------------------------------------%
	function UserAbort()
		ManagerStatus('user aborted. workers are being notified...','error');
		err	= 'user aborted.';
		
		ClosePool(pool);
	end
	%--------------------------------------------------------------------------%
end
	
	%--------------------------------------------------------------------------%
	function bContinue = FinishedTask(kWorker,client,kTask,param)
	%let the manager know we finished a task
		WorkerStatus(kWorker,sprintf('finished task %d',kTask),'most',param);
		
		reply	= WorkerMessage(kWorker,client,param.msg.FINISHED_TASK,param);
		
		bContinue	= reply.message==param.msg.CONTINUE;
	end
	%--------------------------------------------------------------------------%
	function reply = WorkerMessage(kWorker,client,msg,param)
	%the workers use this to send messages to the manager
		WorkerStatus(kWorker,sprintf('sending message %s to the manager',tostring(msg)),'all',param);
		
		reply	= client.Send(msg);
		
		WorkerStatus(kWorker,sprintf('received reply %s from the manager',tostring(reply.message)),'all',param);
	end
	%--------------------------------------------------------------------------%
	function WorkerStatus(kWorker,strStatus,level,param,varargin)
	%the worker uses this to display a log message
		param.log.Print(sprintf('worker %d: %s',kWorker,strStatus),level,varargin{:});
	end
	%--------------------------------------------------------------------------%
	function WorkerError(kWorker,client,kTask,me,param)
	%an error occurred on a task
		if ischar(kTask)
			msg	= sprintf('error while processing task reply "%s"',kTask);
		else
			msg	= sprintf('error on task %d',kTask);
		end
		
		WorkerStatus(kWorker,msg,'error',param,'exception',me);
		
		WorkerMessage(kWorker,client,param.msg.ERROR,param);
	end
	%--------------------------------------------------------------------------%
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function cOut = MultiTaskSerial(f,cIn,param)
%good ol' for loop
	nTask	= numel(f);
	nOut	= param.nout;
	
	if param.catch
		for kT=1:nTask
			try
				[cOut{kT}{1:nOut}]	= f{kT}(cIn{kT}{:});
			catch me
				TaskError(kT,me);
			end
			
			progress('name',param.progress);
		end
	else
		for kT=1:nTask
			[cOut{kT}{1:nOut}]	= f{kT}(cIn{kT}{:});
			
			progress('name',param.progress);
		end
	end
	
	%--------------------------------------------------------------------------%
	function TaskError(kTask,me)
	%an error occurred on a task
		param.log.Print(sprintf('error on task %d',kTask),'error','exception',me);
	end
	%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%
