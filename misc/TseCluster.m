classdef TseCluster < handle

% TseCluster (Version 0.3)
%
% Description: class to manage Tse lab analysis cluster via Matlab's job scheduler and 
%			   distributed computing engine / toolbox
%
% Syntax: tc = TseCluster(nCore,[cHost] = {},[nWorker] = [],<options>)
%
% In: 
%		nCore		- the total number of matlab workers to use for processing this job 
%		[cHost]		- a cell of analysis computer names to use for processing this job
%		[nWorker]	- an array the same size as cHost that indicates the number of workers
%					  to use on the corresponding host
%	options:
%		manager   - (<hostname>) the analysis computer to use as the manager for this job
%		jobname   - (<auto>) a descriptive, short name for this job (e.g gridop-te)
%		silent    - (false) true to suppress status messages
%
% Out:
%		tc - an instance of the TseCluster class
%
% Methods:
%		TseCluster - constructor function, initialize all servers, the manager, and all workers
%					 and start the cluster
%		Close  	   - stop all servers, the manager, and all workers for this job
%		Run 	   - run a task on the cluster (this is really just for testing purposes)
%
% Updated: 2015-06-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com) and Scottie Alexander
% (scottiealexander11@gmail.com).  This work is licensed under a Creative
% Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

%PRIVATE PROPERTIES------------------------------------------------------------%
properties (SetAccess=private)
	nCore   = [];
	debug   = 0;
	silent  = false;
	cluster = [];
	opened;
	hostname;
	bin;
	all_jobs  = {};
	jobname;
	manager   = struct('host','','status','stopped');
	servers   = struct;
	all_hosts = {'ebbinghaus','fechner','helmholtz','wertheimer','wundt','ramonycajal'};
end
%PRIVATE PROPERTIES------------------------------------------------------------%

%METHODS-----------------------------------------------------------------------%
methods
	%--------------------------------------------------------------------------%
	function tc = TseCluster(nCore,varargin)
		if ~isunix
			error('Sorry, but this code only works on *nix systems...');
		end

		if str2double(getfield(ver('distcomp'),'Version')) < 6
			error('This code requires Matlab 2012a or later...');
		end

		[~,tc.hostname] = system('printf "%s" $HOSTNAME');
		
		tc.bin = fullfile(matlabroot,'toolbox','distcomp','bin');		

		tc.nCore = nCore;

		tc.ValidateInput(varargin{:});
		tc.ServerStatus;
		tc.InitializeWorkers;
		tc.Start;
	end
	%--------------------------------------------------------------------------%
	function Start(tc)
		tc.Server('start');
		tc.Manager('start');
		tc.Worker('start');
		tc.InitCluster;
		tc.opened = true;
	end
	%--------------------------------------------------------------------------%
	function Close(tc)
		tc.Worker('stop');
		tc.Manager('stop');
		tc.Server('stop');
	end	
	%--------------------------------------------------------------------------%
	function out = Run(tc,f,inp,n)
	% tc.Run
	%
	% Description: run a job on a cluster, ***note this is for testing only***
	%
	% Syntax: out = tc.Run(f,inp,nOut)
	%
	% In:
	%		f    - the handle to a function to run
	%		inp  - a cell of inputs for f 
	%		nOut - the number of outputs to ask for from f
	%
	% Updated: 2014-03-27

		if isempty(tc.cluster)
			tc.InitCluster;
		end

		job  = createJob(tc.cluster);

		try
			task = createTask(job,f,n,inp);
			
			submit(job);
			wait(job);
			
			out = fetchOutputs(job);
			
			tc.CleanUp(task);
			tc.CleanUp(job);
		catch me
			if exist('task','var')
				tc.CleanUp(task);
			end
			tc.CleanUp(job);
			rethrow(me);
		end
	end
	%--------------------------------------------------------------------------%
end
%METHODS-----------------------------------------------------------------------%

%PRIVATE METHODS---------------------------------------------------------------%
methods %(Access=private)
	%--------------------------------------------------------------------------%
	function pc = InitCluster(tc)
		if strcmpi(tc.manager.status,'running')
			tc.cluster = parallel.cluster.MJS(...
				'Name'		, tc.jobname		,...
				'Host'		, tc.manager.host	...		
				);
		else
			tc.LogMsg(['Manager ' tc.manager.host ' is not running!'],'[ERROR]');
			error('see above...');	
		end
	end
	%--------------------------------------------------------------------------%
	function Server(tc,cmd,varargin)
		%start or stop a group of Matlab cluster servers
		cServers = ParseArgs(varargin,fieldnames(tc.servers));
		cServers = ForceCell(cServers);
		bStop = strcmpi(cmd,'stop');		

		%add hosts one at a time to use correct identity file!
		if ~isempty(cServers)
			for k = 1:numel(cServers)
				tc.SetServerState(cServers{k},cmd);
			end
		end
	end
	%--------------------------------------------------------------------------%
	function SetServerState(tc,host,state)
		tc.LogMsg([state 'ing ' host]);
		bStop = strcmpi(state,'stop');
		s = tc.ServerStatus(host);
		if strcmpi(s.status,'stopped') ~= bStop
			if bStop				
				b = arrayfun(@(x) ~strcmpi(x.job_manager,tc.jobname),s.workers);
				if any(b)
					tc.LogMsg(['Host ' host ' has workers running another job. Leaving mdce running...']);
					return;
				end
			end

			if any(strcmpi(host,tc.hostname))
				cmd = 'mdce';
				inp = {''};
			else
				cmd = 'remotemdce';
				inp = tc.GetRemoteOptions(host);
			end
			if bStop
				inp = [inp {'-clean'}];
				status = 'stopped';
			else
				status = 'running';
			end				    
			if ~tc.RunMdceCmd(cmd,state,inp{:})
				tc.LogMsg(['Failed to ' state ' mdce on host ' host],'[WARNING]');
			elseif isfield(tc.servers,host)
				tc.servers.(host).status = status;
			end
		end
	end
	%--------------------------------------------------------------------------%
	function Manager(tc,cmd)
		%start or stop a Matlab Job Manager
		bStop = strcmpi(cmd,'stop');

		tc.LogMsg([cmd 'ing manager']);
		
		if ~tc.MdceStatus(tc.manager.host) && ~bStop
			tc.Server('start',tc.manager.host);
		end

		cmd = [cmd 'jobmanager'];
		inp = {'-name', tc.jobname};
		if ~strcmpi(tc.manager.host,tc.hostname)
			inp = [inp {'-remotehost',[tc.manager.host '.dartmouth.edu']}];
		end

		if bStop
			inp = [inp {'-clean'}];
			status = 'stopped';
		else
			status = 'running';
		end

		if strcmpi(tc.manager.status,'stopped') ~= bStop
			if tc.MdceStatus(tc.manager.host)
				if ~tc.RunMdceCmd(cmd,inp{:})
					tc.LogMsg(['Failed to ' cmd ' on host ' tc.manager.host],'[WARNING]');
				else
					tc.manager.status = status;
				end
			else
				tc.manager.status = 'stopped';
			end
		end

		if bStop && ~any(strcmpi(tc.manager.host,fieldnames(tc.servers)))
			tc.Server('stop',tc.manager.host);
		end
	end
	%--------------------------------------------------------------------------%
	function Worker(tc,cmd)
		%start or stop Matlab cluster workers

		tc.LogMsg([cmd 'ing workers']);
		
		if strcmpi(cmd,'start')
			bStop = false;
			cOpt = {'-jobmanager',tc.jobname,'-jobmanagerhost',tc.manager.host};
			status = 'Idle';
		elseif strcmpi(cmd,'stop')
			bStop = true;			
			cOpt = {'-clean'};
			status = 'stopped';
		end

		cmd = [cmd 'worker'];

		cServers = fieldnames(tc.servers);
		for kS = 1:numel(cServers)
			if ~tc.MdceStatus(cServers{kS})
				tc.LogMsg(['Host ' cServers{kS} ' is not running!'],'[WARNING]');
				continue;
			end
			workers = tc.servers.(cServers{kS}).workers;
			for kW = 1:numel(workers)
				if bStop == ~strcmpi(workers(kW).status,'stopped')
					inp = [{'-name', workers(kW).name} cOpt];
					if ~strcmpi(tc.hostname,cServers{kS})
						inp = [inp {'-remotehost',[cServers{kS} '.dartmouth.edu']}];
					end					
					if ~tc.RunMdceCmd(cmd,inp{:})
						tc.LogMsg(['Failed to ' cmd ' worker ' workers(kW).name ' on host ' cServers{kS}],'[WARNING]');
					else
						tc.servers.(cServers{kS}).workers(kW).status = status;
					end
				end
			end
		end
		tc.ServerStatus;
	end
	%--------------------------------------------------------------------------%
	function varargout = ServerStatus(tc,varargin)
		hosts = ParseArgs(varargin,fieldnames(tc.servers));
		hosts = ForceCell(hosts);
		cOut = cell(size(hosts));
		for kH = 1:numel(hosts)
			if tc.MdceStatus(hosts{kH})
				cOut{kH}.status  = 'running';
				if strcmpi(hosts{kH},tc.hostname)
					opt = {''};
				else
					opt = {'-remotehost',hosts{kH}};
				end

				[~,out] = tc.RunMdceCmd('nodestatus','-infolevel','1',opt{:});

				[sMgr,sWkr] = tc.ParseStatus(out);
					
				if isfield(tc.servers,hosts{kH})
					tc.servers.(hosts{kH}).status = 'running';
					for k = 1:numel(sWkr)
						if strcmpi(sWkr(k).job_manager,tc.jobname) && nargout < 1
							tc.SetWorkerStatus(hosts{kH},sWkr(k).name,sWkr(k).status);
						end
					end
				end

				if nargout > 0
					cOut{kH}.manager = sMgr;
					cOut{kH}.workers = sWkr;
				end
			else
				cOut{kH}.status  = 'stopped';
				if isfield(tc.servers,hosts{kH})
					tc.servers.(hosts{kH}).status = 'stopped';
				end
				if nargout > 0
					cOut{kH}.manager = [];
					cOut{kH}.workers = [];
				end
			end
		end

		if numel(hosts) == 1 && nargout
			varargout{1} = cOut{1};
		elseif nargout
			varargout{1} = cOut;
		end
	end
	%--------------------------------------------------------------------------%
	function SetWorkerStatus(tc,host,name,status)
		b = strcmpi(name,{tc.servers.(host).workers(:).name});
		if ~any(b)
			tc.servers.(host).workers(end+1).name = name;
			tc.servers.(host).workers(end).host   = host;
			tc.servers.(host).workers(end).status = status;
		else
			tc.servers.(host).workers(b).status   = status;
		end
	end
	%--------------------------------------------------------------------------%
	function b = MdceStatus(tc,host)
		if strcmpi(host,tc.hostname)
			cmd = 'mdce';
			inp = {''};
		else
			cmd = 'remotemdce';
			inp = tc.GetRemoteOptions(host);
		end		
		[b,out] = tc.RunMdceCmd(cmd,'status',inp{:});
		re = regexp(out,'MATLAB Distributed Computing Server is (?<state>\w+)','names');
		if ~isempty(re)			
			b = ~strcmpi(re.state,'stopped');
		else
			tc.LogMsg(['Failed to get state of mdce on host ' host],'[WARNING]');
			b = false;
		end
	end
	%--------------------------------------------------------------------------%
	function [b,out] = RunMdceCmd(tc,cmd,varargin)
		%run a MDCE system command
		script = fullfile(tc.bin,cmd);

		script = [script ' ' strjoin(reshape(varargin,1,[]),' ')];
		if ~ismember(cmd,{'mdce','remotemdce'}) && tc.debug
			script = [script ' -v'];
		end

		if tc.debug
			tc.LogMsg(script);
			b   = false;
			out = 'debug mode is on, no output available';
		end

		if tc.debug < 2
			[b,out] = system(script);
		end

		b = ~b;
		if ~b
			fprintf('*****\n[SYSCMD ERROR]:\n%s\n*****\n',out);
		end
	end
	%--------------------------------------------------------------------------%
	function [b,out] = RunSysCmd(tc,cmd,varargin)
	%run a non-mdce system command on the local or remote host
		host = tc.hostname;
		if ~isempty(varargin) && ~isempty(varargin{1}) && ischar(varargin{1})
			if ismember(varargin{1},tc.all_hosts)
				host = varargin{1};
			end
		end

		if ~strcmp(host,tc.hostname)
			cmd = ['ssh ' host ' ''' cmd '''']; %***
		end

		[b,out] = system(cmd);
		b = ~b;
	end	
	%--------------------------------------------------------------------------%
	function inp = GetRemoteOptions(tc,host)
		strPathId = ['/home/tselab/.ssh/keys/id_rsa_' host];
		if exist(strPathId,'file') ~= 2
			tc.LogMsg(['cannot find identityfile for host ' host]);			
		end
		strHostAddr = [host '.dartmouth.edu'];
		inp = {'-protocol'     , 'ssh'       ,...
			   '-username'     , 'tselab'    ,...
			   '-identityfile' , strPathId   ,...
			   '-remotehost'   , strHostAddr ,...
			   '-passphrase'   , '""'        ,...
			   };
	end
	%----------------------------------------------------------------------%
	function InitializeWorkers(tc,varargin)
		%generate worker names for the given host
		hosts = ParseArgs(varargin,fieldnames(tc.servers));
		hosts = ForceCell(hosts);
		for kH = 1:numel(hosts)
			if isfield(tc.servers,hosts{kH})
				if isfield(tc.servers.(hosts{kH}),'workers') && isstruct(tc.servers.(hosts{kH}).workers)
					cName = {tc.servers.(hosts{kH}).workers(:).name};
				else
					cName = {};
				end
				for k = 1:tc.servers.(hosts{kH}).use
					name = [hosts{kH} '_' sprintf('%02d',k)];
					if isempty(cName) || ~any(strcmpi(name,cName))
						tc.servers.(hosts{kH}).workers(k) = struct('name',name,'host',hosts{kH},'status','stopped');
					end
				end
			end
		end
	end
	%--------------------------------------------------------------------------%
	function [nFree,nTotal] = GetServerResources(tc,host)
	%get the approx. number of free processors on host(s)
		if ~iscell(host)
			host = {host};
		end
		nHost = numel(host);
		[nFree,nTotal] = deal(NaN(nHost,1));
		nCheck = 6;

		for kA = 1:nHost
			[total,idle,usage] = deal(0);

			tc.LogMsg(['Querying state of host: ',host{kA}]);
			nTotal(kA) = tc.GetProcessorCount(host{kA});
			usage = nan(nCheck-1,1);
			for kB = 1:nCheck
				[cur_idle,cur_total] = tc.GetCPUTime(host{kA});

				d_idle  = cur_idle  - idle;
				d_total = cur_total - total;
				d_usage = (d_total  - d_idle)/d_total;

			    %discard the first reading as it is wildly inaccurate
				if kB > 1
					usage(kB-1,1) = d_usage;
				end
				total = cur_total;
				idle = cur_idle;
			    
				pause(.1);
			end

			%our estimate has been shown emperically to be low so round up
			nFree(kA) = ceil(nTotal(kA) - (nanmean(usage) * nTotal(kA)));
			tc.LogMsg(sprintf('\b\b\b\t| %d cores free',nFree(kA)),'');
		end

	end
	%-----------------------------------------------------------------------------%
	function [idle,total] = GetCPUTime(tc,host)
		[b,out]  = tc.RunSysCmd('grep "^cpu\s" /proc/stat',host);
		total = str2double(regexp(out,'\s+','split'));

		idle  = total(5);
		total = sum(total(~isnan(total)));
	end
	%--------------------------------------------------------------------------%
	function n = GetProcessorCount(tc,host)
	    [b,out] = tc.RunSysCmd('grep -c "^processor" /proc/cpuinfo',host);
	    n = str2double(out);
	end
	%--------------------------------------------------------------------------%
	function GetResources(tc,hosts,nWorker)
		%NOTE: strategy, check => prompt => assign
		[hosts,nWorker] = varfun(@(x) reshape(x,[],1),hosts,nWorker);
		force = false;
		if strcmpi(hosts{1},'auto')
			hosts   = reshape(tc.all_hosts,[],1);
			nWorker = NaN(size(hosts));
			auto = true;
		else
			auto = false;
		end		

		[nFree,nTotal] = tc.GetServerResources(hosts);

		%user has requested more workers than host has
		b = nWorker > nTotal;
		if any(b)
			c = [reshape(hosts(b),1,[]);reshape(num2cell(nWorker(b)),1,[]);reshape(num2cell(nTotal(b)),1,[])];
			msg = 'Too many workers requested:';
			msg = [msg char(10) sprintf('\t%s => %d requested, %d cores present\n',c{:})];
			error(msg);
		end

		if tc.nCore > sum(nTotal)
			error('Requested resources cannot run %d workers!',tc.nCore);
		end

		if auto
			[~,kSort] = sort(nFree,'descend');
		else
			%sort by workers but sort NaN entries of workers by nFree
			kSort = tc.sortsort(nWorker,nFree);
		end
		
		[hosts,nWorker,nFree,nTotal] = varfun(@(x) x(kSort),hosts,nWorker,nFree,nTotal);
		bNan = isnan(nWorker);
		[hosts,nWorker,nFree,nTotal] = varfun(@(x) [x(~bNan);x(bNan)],hosts,nWorker,nFree,nTotal);

		%fill in NaN entries in workers so that sum(nWorker) == tc.nCore
		nUse = 0;
		for k = 1:numel(nWorker)
			nNeed = tc.nCore - nUse;
			if ~isnan(nWorker(k))
				%only use as many workers per host as needed
				nWorker(k) = min([nWorker(k) nNeed]);
			else
				%peek ahead and see how many free workers we have available in total
				est = sum(nFree(k:end));
				if (nUse + est) < tc.nCore
					%not enough free so take as many as we need from each host
					nNeed = tc.nCore - (nUse + est);
					nNeed = nFree(k) + nNeed;
					nWorker(k) = min([nTotal(k) nNeed]);
				else
					nWorker(k) = min([nFree(k) nNeed]);
				end
			end
			nUse = nUse+nWorker(k);
		end

		if tc.nCore > nUse
			error('Requested resources cannot run %d workers!',tc.nCore);
		end

		nUse = 0;
		for k = 1:numel(hosts)
			nNeed = tc.nCore - nUse;
			tc.servers.(hosts{k}).free   = nFree(k);
			tc.servers.(hosts{k}).ask    = nWorker(k);
			tc.servers.(hosts{k}).total  = nTotal(k);
			tc.servers.(hosts{k}).status = 'stopped';
			tc.servers.(hosts{k}).use    = nWorker(k);
			
			nUse = nUse + tc.servers.(hosts{k}).use;

			if nUse == tc.nCore
				break;
			end
		end

		if tc.nCore > nUse
			error('Requested resources cannot run %d workers!\n',tc.nCore);
		end
	end
	%--------------------------------------------------------------------------%
	function ValidateInput(tc,varargin)
		%GOAL: fill out hosts is not specified and fill out NaN entries in workers
		% if cHosts/workers cannot run nCore raise an error

		[hosts,nWorker,opt] = ParseArgs(varargin,'auto',NaN,...
				'silent'  , false		,...
				'debug'   , 0 			 ...
				);
				
		tc.manager.host = tc.hostname;
		tc.jobname 	    = ['tsejob-' tc.hostname];
		tc.silent  		= opt.silent;
		tc.debug 		= opt.debug;

		hosts = lower(hosts);
		if iscellstr(hosts)
			b = ismember(hosts,tc.all_hosts);
			if ~all(b)
				error('Invalid hosts requested:\n%s',strjoin(hosts(~b),char(10)));
			end
		elseif ischar(hosts) && ismember(hosts,[reshape(tc.all_hosts,1,[]) {'auto'}])
			hosts = {hosts};
		else
			error('Invalid input for options hosts');
		end

		if ~isnumeric(nWorker) || sum(size(nWorker)>1) > 1
			error('Invalid input for options workers');
		end

		nCore   = numel(nWorker);
		nhost   = numel(hosts);

		if nCore > nhost
			nWorker = nWorker(1:nhost);
		elseif nCore < nhost
			nWorker = [reshape(nWorker,[],1); nan(nhost-nCore,1)];
		end

		nWorker = reshape(nWorker,[],1);
		hosts   = reshape(hosts,[],1);

		%reorder to put user specified workers first
		bNan    = isnan(nWorker);
		nWorker = [nWorker(~bNan);nWorker(bNan)];
		hosts   = [hosts(~bNan);hosts(bNan)];

		tc.GetResources(hosts,nWorker);
	end
	%--------------------------------------------------------------------------%
	function LogMsg(tc,str,varargin)
		if ~tc.silent
			if ~isempty(varargin) && ischar(varargin{1})
				type = varargin{1};
			else
				type = 'INFO';
			end			
			fprintf('%s: %s\n',type,str);
		end
	end
	%--------------------------------------------------------------------------%
end
%PRIVATE METHODS---------------------------------------------------------------%

%STATIC METHODS----------------------------------------------------------------%
methods (Static=true,Access=private)
	%--------------------------------------------------------------------------%
	function [sMgr,sWkr] = ParseStatus(str)

		re = regexp(str,'(?<type>[\w\s]+):\s+(?<cont>[\w\s]+)\n\n','names');

		cType = cellfun(@(x) strtrim(lower(strrep(x,' ','_'))),{re(:).type},'uni',false);
		cS = arrayfun(@(x) str2struct(x.cont),re,'uni',false);

		for k = 1:numel(cS)
			cS{k}.type = cType{k};
			if ~isfield(cS{k},'status')
				cS{k}.status = '';
			end
		end

		bMgr = cellfun(@(x) strcmpi(x.type,'job_manager'),cS);
		bWkr = cellfun(@(x) strcmpi(x.type,'worker'),cS);
		sWkr = [cS{bWkr}];
		sMgr = [cS{bMgr}];
		%----------------------------------------------------------------------%
		function s = str2struct(str)
			str2 = regexprep(str,' {4,}','\t');
			str2 = regexprep(str2,'\n\s+','\n');
			re2  = regexp(str2,'(?<field>[\w ]*)\t+(?<val>[\w ]*)\n?','names');	
			fields = cellfun(@(x) strtrim(lower(strrep(x,' ','_'))),{re2(:).field},'uni',false);
			vals = {re2(:).val};
            s = struct;
            for kF = 1:numel(fields)
                if isfield(s,fields{kF})
                    cur_val = reshape(ForceCell(s.(fields{kF})),[],1);
                    s.(fields{kF}) = [cur_val;vals(kF)];
                else
                    s.(fields{kF}) = vals{kF};
                end
            end
		end
		%----------------------------------------------------------------------%
	end
	%--------------------------------------------------------------------------%
	function kSort1 = sortsort(var1,var2)
		kSort1 = nansort(var1,'descend');
		[x,y] = varfun(@(x) x(kSort1),var1,var2);
		b = isnan(x);
		[~,kSort2] = sort(y(b),'descend');
		kSort2 	   = kSort2 + find(b,1,'first')-1;
		kSort1(b)  = kSort1(kSort2);

		%----------------------------------------------------------------------%
		function k = nansort(x,mode)			
			x = reshape(x,[],1);
			[x,k] = sort(x,mode);
			b = isnan(x);
			k = [k(~b);k(b)];
		end
		%----------------------------------------------------------------------%
	end
	%--------------------------------------------------------------------------%
	function CleanUp(obj)
		if numel(obj) > 1
			for k = 1:numel(obj)
				if isobject(obj(k)) && isvalid(obj(k))			
					delete(obj(k));
				end
			end
		else
			if isobject(obj) && isvalid(obj)			
				delete(obj);
			end
		end
	end
	%--------------------------------------------------------------------------%
end
%STATIC METHODS----------------------------------------------------------------%
end


% bPrompt = nFree < nWorker;
% if any(bPrompt)
% 	cPrompt = hosts(bPrompt);
% 	nWorker_ask = nWorker(bPrompt);
% 	free = nFree(bPrompt);
% 	mx = max(cellfun(@length,cPrompt));
% 	str = '';
% 	for k = 1:numel(cPrompt)
% 		tmp = repmat(32,1,mx-length(cPrompt{k}));
% 		tmp = [cPrompt{k} tmp ' | available: %d [requested: %d]\n'];
% 		str = [str sprintf(tmp,free(k),nWorker_ask(k))];
% 	end
% 	intro = ['The following hosts do not have the requested ',...'
% 			 'number of workers available:'];
% 	outro = 'Would you like to force use of all requested workers?';
% 	str   = [intro char([10 10]) str char(10) outro];
% 	resp  = ask(str,'choice',{'Force all','Use available'});

% 	force = strcmpi(resp,'force all');

% 	if ~force
% 		[~,kSort] = sort(nFree,'descend');
% 		[hosts,nWorker,nFree,nTotal] = varfun(@(x) x(kSort),hosts,nWorker,nFree,nTotal);
% 	end
% end