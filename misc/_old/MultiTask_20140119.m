function varargout = MultiTask(f,cIn,varargin)
% MultiTask
% 
% Description:	perform a set of tasks in parallel
% 
% Syntax:	[cOut1,...,cOutN] = MultiTask(f,cIn,<options>)
% 
% In:
% 	f	- a function handle or cell of function handles of the tasks to call
%	cIn	- a cell of input arguments.  each entry of cIn is either an nTask-
%		  length cell or an array that will be passed as the corresponding input
%		  argument to all tasks.
%	<options>:
%		description:	('running tasks') a description of the job
%		nthread:		(<num cores - 1>) number of tasks to execute
%						simultaneously
%		uniformoutput:	(false) true if outputs are all scalar (like cellfun)
%		catch:			(false) true to catch errors
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	cOutK		- a cell or array of the Kth set of outputs
% 
% Updated: 2013-02-05
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%parse the input
	opt	= ParseArgsOpt(varargin,...
			'description'	, 'running tasks'	, ...
			'catch'			, false				, ...
			'nthread'		, []				, ...
			'uniformoutput'	, false				, ...
			'silent'		, false				  ...
			);
	
	if isempty(opt.nthread)
		opt.nthread	= GetNumCores-1;
	end

%prepare the inputs and outputs
	[f,cIn{:}]	= ForceCell(f,cIn{:});
	[f,cIn{:}]	= FillSingletonArrays(f,cIn{:});
	
	nTask	= numel(f);
	sTask	= size(f);
	nIn		= numel(cIn);
	
	cIn	= cellfun(@(varargin) varargin,cIn{:},'UniformOutput',false);
	
	nOut	= nargout;
	cOut	= repmat({cell(nOut,1)},[nTask 1]);
	
	if nTask==0
		[varargout{1:nOut}]	= deal([]);
		return;
	end

%prepare the jobs
	bMulti	= opt.nthread>1;
	
	if bMulti
	%make sure we have a good cluster size
		sch	= findResource;
		if get(sch,'ClusterSize')<opt.nthread
			set(sch,'ClusterSize',opt.nthread)
		end
	
	%open the pool
		nPool	= matlabpool('size');
		
		if nPool~=opt.nthread
			if nPool>0
				if opt.silent
					evalc('matlabpool close;');
				else
					matlabpool close;
				end
			end
			
			if opt.silent
				evalc('matlabpool(opt.nthread);');
			else
				matlabpool(opt.nthread);
			end
		end
	end
%prepare the progress timer
	if ~opt.silent
		pName	= progress(nTask,'label',[opt.description ' (' num2str(opt.nthread) ' thread' plural(opt.nthread,'','s') ')']);
		
		strDirProgress	= GetTempDir;
		CreateDirPath(strDirProgress);
		
		tmr		= timer('TimerFcn',@ProgressTimer,'Period',0.5,'ExecutionMode','fixedSpacing','UserData',{strDirProgress pName});
		
		start(tmr);
	end
%execute!
	if bMulti
		parfor kT=1:nTask
			if opt.catch
				try
					[cOut{kT}{1:nOut}]	= f{kT}(cIn{kT}{:});
				catch me
					status(['Error on task ' num2str(kT) ' (' me.identifier ' - ' me.message ')'],'warning',true,'silent',opt.silent);
				end
			else
				[cOut{kT}{1:nOut}]	= f{kT}(cIn{kT}{:});
			end
			
			if ~opt.silent
				t = getCurrentTask();
				
				StepProgress(strDirProgress,t.ID);
			end
		end
	else
		for kT=1:nTask
			if opt.catch
				try
					[cOut{kT}{1:nOut}]	= f{kT}(cIn{kT}{:});
				catch me
					status(['Error on task ' num2str(kT) ' (' me.identifier ' - ' me.message ')'],'warning',true,'silent',opt.silent);
				end
			else
				[cOut{kT}{1:nOut}]	= f{kT}(cIn{kT}{:});
			end
			
			if ~opt.silent
				StepProgress(strDirProgress,1);
			end
		end
	end
	
	if ~opt.silent
		stop(tmr);
		progress('end','name',pName);
		
		rmdir(strDirProgress,'s');
	end
%close the pool
	if bMulti
		if opt.silent
			evalc('matlabpool close;');
		else
			matlabpool close;
		end
	end

%process the outputs
	varargout	= cellfun(@(varargin) reshape(varargin,sTask),cOut{:},'UniformOutput',false);
	
	if opt.uniformoutput
	%convert to numerical arrays?
		bScalar	= cellfun(@(v) cellfun(@isscalar,v),varargout,'UniformOutput',false);
		
		if ~all(cellfun(@(x) all(x(:)),bScalar))
		%convert non-scalars to NaNs
			status('Non-scalar values detected in output.','warning',true,'silent',opt.silent);
			
			varargout	= cellfun(@(b,v) conditional(b,v,NaN),bScalar,varargout,'UniformOutput',false);
		end
		
		varargout	= cellfun(@cell2mat,varargout,'UniformOutput',false);
	end

%------------------------------------------------------------------------------%
function StepProgress(strDirProgress,kWorker)
	fid	= fopen([strDirProgress num2str(kWorker)],'a');
	fwrite(fid,'1','uchar');
	fclose(fid);
%------------------------------------------------------------------------------%
function ProgressTimer(tmr,evt)
	d				= get(tmr,'UserData');
	strDirProgress	= d{1};
	pName			= d{2};
	
	%get the sum from all the progress file sizes
		dr			= dir(strDirProgress);
		kProgress	= sum([dr.bytes]);
	
	progress(kProgress,'name',pName);
%------------------------------------------------------------------------------%

