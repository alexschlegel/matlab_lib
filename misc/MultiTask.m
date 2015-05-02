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
%		njobmax:			(1000) the maximum number of jobs to run in any
%							single batch (large numbers of jobs may cripple
%							worker initialization)
%		bytesmax:			(100000000) the maximum number of bytes of data to
%							include in each batch
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
%		debug_communicator:	('warn') the debug level for the Communicators
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	cOutK	- a cell or array of the Kth set of outputs
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input
	opt	= ParseArgs(varargin,...
			'description'			, 'running tasks'	, ...
			'uniformoutput'			, false				, ...
			'cores'					, []				, ...
			'njobmax'				, 1000				, ...
			'bytesmax'				, 100000000			, ...
			'distributed'			, []				, ...
			'hosts'					, []				, ...
			'workers'				, []				, ...
			'catch'					, false				, ...
			'interface'				, 'inbound'			, ...
			'base_port'				, 30000				, ...
			'debug'					, 'warn'			, ...
			'debug_communicator'	, 'warn'			, ...
			'silent'				, false				  ...
			);
	
	if isempty(opt.cores)
		opt.cores	= GetNumCores-1;
	end

%start the log
	L	= Log('level',opt.debug,'silent',opt.silent);

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
		opt.ntaskfinished	= 0;
	
	bMulti	= opt.cores>1;
	
	if bMulti
	%use the distributed computing toolbox
		%get the total workspace size for each task
			taskBytes	= cellfun(@JobSize,f,cIn);
		
		%execute each batch of jobs
			cOut	= cell(sTask);
			
			kTStart	= 1;
			while kTStart<=nTask
				%get the last job in the batch based on the batch count limit
					kTEndCount	= min(nTask,kTStart+opt.njobmax-1);
				%get the last job in the batch based on variable size
					taskCumBytes	= cumsum(taskBytes(kTStart:end));
					kSmallEnough	= unless(find(taskCumBytes<=opt.bytesmax,1,'last'),1);
					kTEndBytes		= kTStart+kSmallEnough-1;
				%the actual last job in the batch is the minimum of these two
					kTEnd	= min(kTEndCount,kTEndBytes);
				
				%execute the current batch of jobs
					kTaskCur	= kTStart:kTEnd;
					batchBytes	= sum(taskBytes(kTaskCur));
					
					L.Print(sprintf('running jobs %d-%d (%d byte%s)',kTStart,kTEnd,batchBytes,plural(batchBytes)),'info');
				
					cOut(kTaskCur)	= MultiTaskParallel(f(kTaskCur),cIn(kTaskCur),opt);
				
				opt.ntaskfinished	= opt.ntaskfinished + numel(kTaskCur);
				
				kTStart	= kTEnd + 1;
			end
		
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
%distribute the jobs amongst a group of workers
	%turn off some warnings
		warning('off','parallel:cluster:CannotSaveCorrectly');
		warning('off','parallel:cluster:CannotLoadCorrectly');
	
	%some constants
		TASK_UNASSIGNED	= 0;
		TASK_FINISHED	= -1;
		
		msgType	=	{
						'task'
						'test'
						'error'
					};
	
	%figure out some stuff
		nTask	= numel(f);
		nOut	= param.nout;
	
	%open the pool
		nPool	= Pool('open');
		
		if nPool==1
			Pool('close');
			cOut	= MultiTaskSerial(f,cIn,param);
			return;
		end
	
	%prepare some variables
		%so the parallel manager can keep track of tasks
			bSentTask		= false(nPool, 1);
			taskState		= repmat(TASK_UNASSIGNED, [nTask 1]);
			err				= [];
			hTimerProgress	= [];
			bProgressEnd	= false;
	
	%get the tcp/ip ports to use
		port	= freeport(param.base_port,nPool);
	
	%get some function handles
		f_OpenClient	= @OpenClient;
		f_RequestTask	= @RequestTask;
		f_FinishedTask	= @FinishedTask;
		f_CloseClient	= @CloseClient;
		f_WorkerStatus	= @WorkerStatus;
		f_WorkerError	= @WorkerError;
	
	%fork a process to manage the workers
		ipManager	= getip('interface', param.interface);
		hManager	= fork(@ManageWorkers,{nPool},'delay',1);
	
	%execute!
		try
			ManagerStatus('let the workers be!','info');
			
			spmd
				warning('off','parallel:cluster:CannotLoadCorrectly');
				%let the world know we exist
					f_WorkerStatus(labindex,'i am!','info');
				
				%prepare the output
					CompositeOut	= cell(nTask,1);
				
				%open a socket to the manager
					client	= f_OpenClient(labindex);
				
				%get the first task to process
					kTask	= f_RequestTask(labindex,client);
				
				%process tasks until we're done
					while isscalar(kTask)
						%process the task
							try
								CompositeOut{kTask}				= cell(nOut,1);
								[CompositeOut{kTask}{1:nOut}]	= f{kTask}(cIn{kTask}{:});
								
								if ~isempty(CompositeOut{kTask}) && isempty(CompositeOut{kTask}{1})
									f_WorkerStatus(labindex,'empty!!!','warn');
								end
							catch me
								f_WorkerError(labindex,client,kTask,me);
							end
						%let the manager know we are finished and get the next
						%task to process
							kTask	= f_FinishedTask(labindex,client);
					end
				
				%what happened?
					switch class(kTask)
						case 'char'
							switch kTask
								case 'finish'
									f_WorkerStatus(labindex,'finishing!','info');
							end
					end
				
				%close the socket to the manager
					f_CloseClient(labindex,client);
			end
		catch me
			ManagerError(me.message);
		end
	
	%end the manager
		StopManager(hManager);
	
	%merge the outputs
		if isempty(err)
			cOut = cellfun(@(varargin) cat(2,varargin{:}), CompositeOut{:},'uni',false);
			
			bBlank			= cellfun(@isempty,cOut);
			cOut(bBlank)	= {cell(nOut,1)};
		end
	
	%close the pool
		Pool('close');
	
	%did an error occur?
		assert(isempty(err),'an error occurred: %s',err);
%------------------------------------------------------------------------------%
function nPool = Pool(strCmd)
%i have to put both the open and close functionality in a single function so
%i can keep the cluster object internal, since otherwise the labs complain about
%not being able to load cluster objects from MAT files
	persistent pool;
	
	switch lower(strCmd)
		case 'open'
			bSilent	= param.silent || ~param.log.TestLevel('info');
			
			[b,nPool,pool]	= MATLABPoolOpen(param.cores,...
								'ntask'			, nTask				, ...
								'distributed'	, param.distributed	, ...
								'hosts'			, param.hosts		, ...
								'workers'		, param.workers		, ...
								'silent'		, bSilent			  ...
								);
			
			assert(b,'could not open the MATLAB pool.');
		case 'close'
			nPool	= [];
			
			bClose	= unless(GetFieldPath(pool,'opened'),false);
			
			if bClose && ~MATLABPoolClose(pool,'silent',param.silent);
				ManagerStatus('could not close the MATLAB pool.','warn');
			end
	end
end
%------------------------------------------------------------------------------%
function client = OpenClient(kWorker)
%open a client communicator
	strIP	= sprintf('%s:%d',ipManager,port(kWorker));
	
	WorkerStatus(kWorker,sprintf('opening a connection to the manager at %s',strIP),'info');
	
	client	= Communicator(port(kWorker),msgType,ipManager,...
				'debug'		, param.debug_communicator	, ...
				'silent'	, param.silent				  ...
				);
	client.Connect;
	
	WorkerStatus(kWorker,'connection to the manager opened','most');
end
%------------------------------------------------------------------------------%
function CloseClient(kWorker,client)
%close and destroy the client communicator
	WorkerStatus(kWorker,'closing connection to the manager','info');
	
	delete(client);
	
	WorkerStatus(kWorker,'connection to the manager closed','most');
end
%------------------------------------------------------------------------------%
function reply = WorkerMessage(kWorker,client,msgType,msg)
%the workers use this to send messages to the manager
	WorkerStatus(kWorker,sprintf('sending message "%s" to the manager',msg),'all');
	
	reply	= client.Send(msgType,msg);
	
	WorkerStatus(kWorker,sprintf('received reply "%s" from the manager',tostring(reply)),'all');
end
%------------------------------------------------------------------------------%
function kTask = RequestTask(kWorker,client)
%request a task from the manager
	WorkerStatus(kWorker,'requesting a task','most');
	
	reply	= WorkerMessage(kWorker,client,'task','get');
	
	kTask	= ParseTask(kWorker,client,reply);
end
%------------------------------------------------------------------------------%
function kTask = FinishedTask(kWorker, client)
%let the manager know we finished a task and request another one
	WorkerStatus(kWorker,'requesting the next task','most');
	
	reply	= WorkerMessage(kWorker,client,'task','done');
	
	kTask	= ParseTask(kWorker,client,reply);
end
%------------------------------------------------------------------------------%
function kTask = ParseTask(kWorker,client,msg)
%figure out how the manager responded to a task request
	kTask	= GetFieldPath(msg,'message');
	
	switch class(kTask)
		case 'char'
			switch kTask
				case 'finish'
					WorkerStatus(kWorker,'was told to finish','most');
				case 'error'
					WorkerStatus(kWorker,'manager died','warn');
				otherwise
					msg	= sprintf('response "%s" is unrecognized.',kTask);
					me	= MException('MultiTask:invalidresponse',msg);
					WorkerError(kWorker,client,-1,me);
			end
		otherwise
			if isscalar(kTask)
				WorkerStatus(kWorker,sprintf('got task %d',kTask),'most');
			elseif isempty(kTask)
				WorkerStatus(kWorker,'failed to get task','warn');
			else
				msg	= sprintf('response "%s" is unrecognized.',tostring(kTask));
				me	= MException('MultiTask:invalidresponse',msg);
				WorkerError(kWorker,client,-1,me);
			end
	end
end
%------------------------------------------------------------------------------%
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
			servers{kW}	= Communicator(port(kW),msgType,...
							'handler'	, @(com,msg) ProcessWorker(com,msg,kW)	, ...
							'debug'		, param.debug_communicator				, ...
							'silent'	, param.silent							  ...
							);
			
			ManagerStatus(sprintf('listening for worker %d on port %d',kW,port(kW)),'most');
			
			servers{kW}.Connect;
			
			ManagerStatus(sprintf('worker %d found!',kW),'most');
		end
	
	ManagerStatus('all worker connections opened','info');
end
%------------------------------------------------------------------------------%
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
%------------------------------------------------------------------------------%
function ProcessWorker(server,msg,kWorker)
%process a message from the worker
	str	= sprintf('processing message %s/%s from worker %d',msg.type,tostring(msg.message),kWorker);
	ManagerStatus(str,'all');
	
	%what to do?
		reply	= 'received';
		
		switch msg.type
			case 'task'
				switch msg.message
					case 'get'
					%worker needs a task
						reply	= FindNextTask(kWorker);
					case 'done'
					%worker is done with its task
						%which task was the worker working on?
							kTaskFinished	= find(taskState==kWorker);
						%mark it as finished
							taskState(kTaskFinished)	= TASK_FINISHED;
						%send the worker the next task
							reply	= FindNextTask(kWorker);
				end
			case 'test'
			%worker sent a test message
				ManagerStatus(sprintf('received test message from worker %d',kWorker),'all');
			case 'error'
			%worker experienced an error
				ManagerError(msg.message);
		end
	%send the reply
		ManagerStatus(sprintf('sending reply %s to worker %d',tostring(reply),kWorker),'all');
		
		server.Reply(msg,reply);
end
%------------------------------------------------------------------------------%
function kTask = FindNextTask(kWorker)
%find the next unassigned task
	kTask	= find(taskState==TASK_UNASSIGNED,1);
	
	if isempty(kTask) || ~isempty(err)
	%finished!
		kTask	= 'finish';
		
		ManagerStatus(sprintf('telling worker %d to finish',kWorker),'most');
	else
		%assign the task to the worker
			taskState(kTask)	= kWorker;
		
		ManagerStatus(sprintf('sending task %d to worker %d',kTask,kWorker),'most');
	end
end
%------------------------------------------------------------------------------%
function WorkerStatus(kWorker,strStatus,level,varargin)
%the worker uses this to display a log message
	param.log.Print(sprintf('worker %d: %s',kWorker,strStatus),level,varargin{:});
end
%------------------------------------------------------------------------------%
function ManagerStatus(strStatus, level, varargin)
%the manager users this to display a log message
	param.log.Print(sprintf('manager: %s',strStatus),level,varargin{:});
end
%------------------------------------------------------------------------------%
function WorkerError(kWorker,client,kTask,me)
%an error occurred on a task
	if ischar(kTask)
		msg	= sprintf('error while processing task reply "%s"',kTask);
	else
		msg	= sprintf('error on task %d',kTask);
	end
	
	WorkerStatus(kWorker,msg,'error','exception',me);
	
	WorkerMessage(kWorker,client,'error',me.message);
end
%------------------------------------------------------------------------------%
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
%------------------------------------------------------------------------------%
function UpdateProgress(tmr,evt)
%update the progress bar
	nTaskFinished	= sum(taskState==TASK_FINISHED);
	
	try
		if ~bProgressEnd
			progress('current',param.ntaskfinished + nTaskFinished,'name',param.progress);
		end
		
		if nTaskFinished==nTask
			bProgressEnd	= true;
		end
	catch me
		UserAbort();
		stop(tmr);
	end
end
%------------------------------------------------------------------------------%
function UserAbort()
	ManagerStatus('user aborted. workers are being notified...','error');
	err	= 'user aborted.';
	
	Pool('close');
end
%------------------------------------------------------------------------------%
end


%------------------------------------------------------------------------------%
function cOut = MultiTaskSerial(f,cIn,param)
%good ol' for loop
	nTask	= numel(f);
	nOut	= param.nout;
	
	for kT=1:nTask
		try
			[cOut{kT}{1:nOut}]	= f{kT}(cIn{kT}{:});
		catch me
			TaskError(kT,me);
		end
		
		progress('name',param.progress);
	end
%------------------------------------------------------------------------------%
function TaskError(kTask,me)
%an error occurred on a task
	if param.catch
		param.log.Print(sprintf('error on task %d',kTask),'error','exception',me);
	else
		progress('action','end','name',param.progress);
		rethrow(me);
	end
end
%------------------------------------------------------------------------------%
end

%------------------------------------------------------------------------------%
function bytes = JobSize(f,cIn)
	bytes	= varsize(cIn) + varsize(GetFieldPath(functions(f),'workspace'));
end
%------------------------------------------------------------------------------%
