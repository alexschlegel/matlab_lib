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
%	cIn	- a cell of input arguments.  each entry of cIn is either an nTask-
%		  length cell, in which case each element of the cell will be used as an
%		  input argument for a separate call to f, or an array that will be
%		  passed as the corresponding input argument to all tasks.
%	<options>:
%		description:		('running tasks') a description of the job
%		nthread:			(<num cores - 1>) number of tasks to execute
%							simultaneously
%		distributed:		(<auto>) true to use the distributed computing
%							engine
%		hosts:				(<auto>) the hosts to use (see MATLABPoolOpen)
%		workers:			(<auto>) the numbers of workers to use on each host
%							(see MATLABPoolOpen)
%		uniformoutput:		(false) true if outputs are all scalar (like
%							cellfun)
%		catch:				(false) true to catch errors without killing the
%							entire job
%		interface:			('inbound') the interface to use for manager/worker
%							communication (see getip)
%		debug:				('warn') the debug level (either 'error', 'warn',
%							'info', 'most', or 'all')
%		debug_communicator:	('warn') the debug level for the Communicators
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	cOutK		- a cell or array of the Kth set of outputs
% 
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
BASE_PORT = 30000;

TASK_UNASSIGNED	= 0;
TASK_FINISHED	= -1;

msgType	=	{
				'task'
				'test'
				'error'
			};

warning('off','parallel:cluster:CannotSaveCorrectly');
warning('off','parallel:cluster:CannotLoadCorrectly');

%parse the input
	opt	= ParseArgs(varargin,...
			'description'			, 'running tasks'	, ...
			'nthread'				, []				, ...
			'distributed'			, []				, ...
			'hosts'					, []				, ...
			'workers'				, []				, ...
			'uniformoutput'			, false				, ...
			'catch'					, false				, ...
			'interface'				, 'inbound'			, ...
			'debug'					, 'warn'			, ...
			'debug_communicator'	, 'warn'			, ...
			'silent'				, false				  ...
			);
	
	if isempty(opt.nthread)
		opt.nthread	= GetNumCores-1;
	end
	
	L	= Log('level',opt.debug, 'silent', opt.silent);

%prepare the inputs and outputs
	[f,cIn{:}]	= ForceCell(f,cIn{:});
	[f,cIn{:}]	= FillSingletonArrays(f,cIn{:});
	
	if any(0==cellfun(@numel,cIn))
		f	= [];
	end
	
	nTask	= numel(f);
	sTask	= size(f);
	nIn		= numel(cIn);
	
	nOut	= nargout;
	cOut	= repmat({cell(nOut,1)},[nTask 1]);
	
	if nTask==0 || nIn==0
		[varargout{1:nOut}]	= deal([]);
		return;
	end
	
	if nIn~=0
		cIn	= cellfun(@(varargin) varargin,cIn{:},'UniformOutput',false);
	end

%prepare the progress bar
	strLabel	= [opt.description ' (' num2str(opt.nthread) ' thread' plural(opt.nthread,'','s') ')'];
	pName		= progress(nTask,'label',strLabel,'silent',opt.silent);

%execute the jobs
	bMulti	= opt.nthread>1;
	
	if bMulti
	%engage
		%so the parallel manager can keep track of tasks
			taskState		= repmat(TASK_UNASSIGNED, [nTask 1]);
			err				= [];
			hTimerProgress	= [];
			bProgressEnd	= false;
		%for communication
			port	= [];
		
		MultiTaskParallel;
	else
	%just a regular old for loop
		MultiTaskSerial;
	end

%process the outputs
	varargout	= cellfun(@(varargin) reshape(varargin,sTask),cOut{:},'UniformOutput',false);
	
	if opt.uniformoutput
	%convert to numerical arrays?
		bScalar	= cellfun(@(v) cellfun(@isscalar,v),varargout,'UniformOutput',false);
		
		if ~all(cellfun(@(x) all(x(:)),bScalar))
		%convert non-scalars to NaNs
			L.Print('Non-scalar values detected in output.','warn');
			
			varargout	= cellfun(@(b,v) conditional(b,v,NaN),bScalar,varargout,'UniformOutput',false);
		end
		
		varargout	= cellfun(@cell2mat,varargout,'UniformOutput',false);
	end


%------------------------------------------------------------------------------%
function MultiTaskParallel()
%distribute the jobs amongst a group of workers
	%open the pool
		nPool 		= Pool('open');
		
		if nPool==1
			Pool('close');
			MultiTaskSerial;
			return;
		end
		
		bSentTask	= false(nPool, 1);
	
	%get the tcp/ip ports to use
		port	= freeport(BASE_PORT,nPool);
	
	%get some function handles
		POpenClient		= @OpenClient;
		PRequestTask	= @RequestTask;
		PFinishedTask	= @FinishedTask;
		PCloseClient	= @CloseClient;
		PWorkerStatus	= @WorkerStatus;
		PWorkerError	= @WorkerError;
	
	%get the total workspace size for the tasks
		bytesIn		= varsize(cIn);
		bytesF		= sum(cellfun(@(f) varsize(GetFieldPath(functions(f),'workspace')),reshape(f,[],1)));
		bytesTotal	= bytesIn + bytesF;
		
		if bytesTotal > 50000000
			ManagerStatus(sprintf('Total workspace size of tasks is %d byte%s.',bytesTotal,plural(bytesTotal,'{,s}')),'warn');
		end
         
	%fork a process to manage the workers
		ipManager	= getip('interface', opt.interface);
		hManager	= fork(@ManageWorkers,{ipManager,nPool},'delay',1);
	
	%execute!
		try
			ManagerStatus('Let the workers be!', 'info');
			
			spmd
				warning('off','parallel:cluster:CannotLoadCorrectly');
				
				PWorkerStatus(labindex, 'I am!', 'info');
				
				CompositeOut	= cell(nTask,1);
				
				%open a socket to the manager
					client	= POpenClient(labindex, ipManager);
				
				%get the first task to process
					kTask	= PRequestTask(labindex, client);
				
				%process tasks until we're done
					while isscalar(kTask)
						%process the task
							try
								CompositeOut{kTask}				= cell(nOut,1);
								[CompositeOut{kTask}{1:nOut}]	= f{kTask}(cIn{kTask}{:});
								
								%***
								if ~isempty(CompositeOut{kTask}) && isempty(CompositeOut{kTask}{1})
									PWorkerStatus(labindex,'empty!!!','warn');
								end
							catch me
								PWorkerError(labindex, client, kTask, me);
							end
						%get the next task to process
							kTask	= PFinishedTask(labindex, client);
					end
					switch class(kTask)
						case 'char'
							switch kTask
								case 'finish'
									PWorkerStatus(labindex, 'finishing!', 'info');
							end
					end
				
				%close the socket to the manager
					PCloseClient(labindex, client);
			end
		catch me
			ManagerError(me.message);
		end
	
	%end the manager
		StopManager(hManager);
	
	%merge the outputs
		if ~err
			cOut = cellfun(@(varargin) cat(2,varargin{:}), CompositeOut{:},'uni',false);
			
			bBlank			= cellfun(@isempty,cOut);
			cOut(bBlank)	= {cell(nOut,1)};
		end
	
	%close the pool
		Pool('close');
	
	%did an error occur?
		if err
			error('An error occurred: %s',err);
		end
end
%------------------------------------------------------------------------------%
function nPool = Pool(strCmd)
%i have to put both the open and close functionality in a single functions so
%i can keep the cluter object internally, since the labs complain about not
%being able to load cluster objects from MAT files otherwise
	persistent pool;
	
	nPool	= [];
	
	switch lower(strCmd)
		case 'open'
			[bSuccess,nPool,pool]	= MATLABPoolOpen(opt.nthread,...
										'ntask'			, nTask									, ...
										'distributed'	, opt.distributed						, ...
										'hosts'			, opt.hosts								, ...
										'workers'		, opt.workers							, ...
										'silent'		, opt.silent || ~L.TestLevel('info')	  ...
										);
			
			if ~bSuccess
				error('Could not open the MATLAB pool.');
			end
		case 'close'
			bClose	= unless(GetFieldPath(pool,'opened'),false);
			
			if bClose && ~MATLABPoolClose(pool,'silent',opt.silent);
				ManagerStatus('Could not close the MATLAB pool.','warn');
			end
	end
end
%------------------------------------------------------------------------------%
function client = OpenClient(kWorker, ipManager)
	strIP	= [ipManager ':' num2str(port(kWorker))];
	
	WorkerStatus(kWorker,['opening a connection to the manager at ' strIP], 'info');
	
	client	= Communicator(port(kWorker), msgType, ipManager,...
				'debug'		, opt.debug_communicator	, ...
				'silent'	, opt.silent				  ...
				);
	client.Connect;
	
	WorkerStatus(kWorker,'connection to the manager opened', 'most');
end
%------------------------------------------------------------------------------%
function reply = WorkerMessage(kWorker, client, msgType, msg)
	WorkerStatus(kWorker, ['sending message "' msg '" to the manager'], 'all');
	
	reply	= client.Send(msgType, msg);
	
	WorkerStatus(kWorker, ['received reply "' tostring(reply) '" from the manager'], 'all');
end
%------------------------------------------------------------------------------%
function CloseClient(kWorker, client)
	WorkerStatus(kWorker, 'closing connection to the manager', 'info');
	
	delete(client);
	
	WorkerStatus(kWorker, 'connection to the manager closed', 'most');
end
%------------------------------------------------------------------------------%
function kTask = RequestTask(kWorker, client)
	WorkerStatus(kWorker, 'requesting a task', 'info');
	
	reply	= WorkerMessage(kWorker, client, 'task', 'get');
	kTask	= ParseTask(kWorker, client, reply);
end
%------------------------------------------------------------------------------%
function kTask = FinishedTask(kWorker, client)
	WorkerStatus(kWorker, 'requesting the next task', 'info');
	
	reply	= WorkerMessage(kWorker, client, 'task', 'done');
	kTask	= ParseTask(kWorker, client, reply);
end
%------------------------------------------------------------------------------%
function kTask = ParseTask(kWorker, client, msg)
	kTask	= GetFieldPath(msg,'message');
	
	switch class(kTask)
		case 'char'
			switch kTask
				case 'finish'
					WorkerStatus(kWorker, 'was told to finish', 'info');
				case 'error'
					WorkerStatus(labindex, 'manager died', 'warn');
				otherwise
					msg	= sprintf('response "%s" is unrecognized.',kTask);
					me	= MException('MultiTask:invalidresponse',msg);
					WorkerError(kWorker, client, -1, me);
			end
		otherwise
			if isscalar(kTask)
				WorkerStatus(kWorker, sprintf('got task %d',kTask), 'info');
			elseif isempty(kTask)
				WorkerStatus(labindex, 'failed to get task', 'warn');
			else
				msg	= sprintf('response "%s" is unrecognized.',tostring(kTask));
				me	= MException('MultiTask:invalidresponse',msg);
				WorkerError(kWorker, client, -1, me);
			end
	end
end
%------------------------------------------------------------------------------%
function servers = ManageWorkers(ipManager, nWorker)
	%start the process to update the progress bar
		hTimerProgress	= timer(...
							'TimerFcn'		, @UpdateProgress			, ...
							'ErrorFcn'		, @(tmr,evt) UserAbort()	, ...
							'Period'		, 0.25						, ...
							'ExecutionMode'	, 'fixedSpacing'			, ...
							'StartDelay'	, 1							  ...
							);
		start(hTimerProgress);
	
	ManagerStatus('opening connections to the workers', 'info');
	
	servers	= cell(nWorker,1);
	
	for kW=1:nWorker
		servers{kW}	= Communicator(port(kW),msgType,...
						'handler'	, @(com, msg) ProcessWorker(com, msg, kW)	, ...
						'debug'		, opt.debug_communicator					, ...
						'silent'	, opt.silent								  ...
						);
		
		ManagerStatus(['listening for Worker ' num2str(kW) ' on port ' num2str(port(kW))], 'most');
		
		servers{kW}.Connect;
		
		ManagerStatus(['Worker ' num2str(kW) ' found!'], 'most');
	end
	
	ManagerStatus('all worker connections opened', 'info');
end
%------------------------------------------------------------------------------%
function StopManager(hManager)
	%stop the progress bar timer
		if ~isempty(hTimerProgress)
			stop(hTimerProgress);
			delete(hTimerProgress);
		end
		
		progress('end','name',pName);
	
	servers	= forkOutput(hManager);
	
	if ~isempty(servers)
		ManagerStatus('closing worker connections', 'info');
		
		cellfun(@delete,servers);
		
		ManagerStatus('all worker connections closed', 'info');
	end
end
%------------------------------------------------------------------------------%
function ProcessWorker(server, msg, kWorker)
%process a message from the worker
	str	= sprintf('processing message %s/%s from worker %d',msg.type,tostring(msg.message),kWorker);
	ManagerStatus(str, 'all');
	
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
				ManagerStatus(sprintf('received test message from Worker %d',kWorker), 'all');
			case 'error'
			%worker experienced an error
				ManagerError(msg.message);
		end
	%send the reply
		ManagerStatus(sprintf('sending reply %s to worker %d',tostring(reply),kWorker),'all');
		
		server.Reply(msg, reply);
end
%------------------------------------------------------------------------------%
function kTask = FindNextTask(kWorker)
%find the next unassigned task
	kTask	= find(taskState==TASK_UNASSIGNED,1);
	
	if isempty(kTask) || ~isempty(err)
	%finished!
		kTask	= 'finish';
		
		ManagerStatus(sprintf('telling worker %d to finish',kWorker),'info');
	else
		taskState(kTask)	= kWorker;
		
		ManagerStatus(sprintf('sending task %d to worker %d',kTask, kWorker),'info');
	end
end
%------------------------------------------------------------------------------%
function WorkerStatus(kWorker, strStatus, level, varargin)
	L.Print(sprintf('Worker %d: %s',kWorker,strStatus),level,varargin{:});
end
%------------------------------------------------------------------------------%
function ManagerStatus(strStatus, level, varargin)
	L.Print(sprintf('Manager: %s',strStatus),level,varargin{:});
end
%------------------------------------------------------------------------------%
function WorkerError(kWorker, client, kT, me)
%an error occurred on a task
	if ischar(kT)
		msg	= sprintf('error while processing task reply "%s"',kT);
	else
		msg	= sprintf('error on task %d',kT);
	end
	
	WorkerStatus(kWorker, msg, 'error', 'exception', me);
	
	WorkerMessage(kWorker, client, 'error', me.message);
end
%------------------------------------------------------------------------------%
function ManagerError(strError)
	if ~opt.catch
		progress('end', 'name', pName);
		err	= strError;
		
		ManagerStatus(sprintf('aborting the job because an error occurred: %s',strError),'error');
	end
end
%------------------------------------------------------------------------------%
function UpdateProgress(tmr,evt)
	nTaskFinished	= sum(taskState==TASK_FINISHED);
	
	try
		if ~bProgressEnd
			progress(nTaskFinished,'name',pName);
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



%------------------------------------------------------------------------------%
function MultiTaskSerial()
%good ol' for loop
	for kT=1:nTask
		try
			[cOut{kT}{1:nOut}]	= f{kT}(cIn{kT}{:});
		catch me
			TaskError(kT,me);
		end
		
		progress('name', pName);
	end
end
%------------------------------------------------------------------------------%
function TaskError(kT, me)
%an error occurred on a task
	if opt.catch
		L.Print(sprintf('error on task %d',kT),'error','exception',me);
	else
		progress('end', 'name', pName);
		
		rethrow(me);
	end
end
%------------------------------------------------------------------------------%


end
