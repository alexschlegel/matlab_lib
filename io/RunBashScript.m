function [vExitCode,cOutput] = RunBashScript(cScript,varargin)
% RunBashScript
% 
% Description:	run a BASH script or set of BASH scripts under an interactive
%				shell
% 
% Syntax:	[vExitCode,cOutput] = RunBashScript(cScript,<options>)
% 
% In:
% 	cScript	- the contents of a shell script, or a cell of script contents to
%			  run multiple scripts
%	<options>:
%		description:	('Running Bash Script') a description of the process
%		file_prefix:	('runbashscript') the prefix to use when constructing
%						script/log paths from directories
%		script_path:	(<don't save>) either the path to which to the
%						scripts, or an nScript-length cell of paths to save each
%						script to a separate file.  if a directory is passed,
%						the script file name is <file_prefix>.sh
%		script_append:	(false) true to append the current scripts to the script
%						files if they already exist, false to overwrite them
%		log_path:		(<don't save>) either the path to which to save the
%						output from all scripts, or a cell of paths to save each
%						script's output separately.  if a directory is passed,
%						the log file name is <file_prefix>.log
%		log_append:		(false) true to append the log files if they already
%						exist, false to overwrite them
%		backup:			(true) true to backup existing script or log files
%						before overwriting them
%		run:			(true) true to run the scripts
%		wait:			(true) true to wait for script execution to finish
%						before returning.  note that logs won't be deleted
%						properly and no status will be returned if this is false
%		debug:			(false) true to display the script
%		cores:			(1) the number of processor cores to use
%		silent:			(false) true to suppress the script output from the
%						MATLAB window
% 
% Out:
%	vExitCode	- an array of script exit codes.  0 should indicate success.
% 	cOutput		- the stdout and stderr output from the script execution (or a
%				  cell of outputs)
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'description'	, 'Running Bash Script'	, ...
		'file_prefix'	, 'runbashscript'		, ...
		'script_path'	, []					, ...
		'script_append'	, false					, ...
		'log_path'		, []					, ...
		'log_append'	, false					, ...
		'backup'		, true					, ...
		'run'			, true					, ...
		'wait'			, true					, ...
		'debug'			, false					, ...
		'cores'			, 1						, ...
		'silent'		, false					  ...
		);

[cScript,bCharOutput]	= ForceCell(cScript);
sScript					= size(cScript);
nScript					= numel(cScript);

%make sure we're in a Unix environment
	assert(isunix,'bash scripts can only be run in a unix environment.');
%format the script/log paths
	cPathScript		= ForceCell(opt.script_path);
	cPathScript		= cellfun(@(fs) conditional(isdir(fs),PathUnsplit(fs,opt.file_prefix,'sh'),fs),cPathScript,'UniformOutput',false);
	bSingleScript	= numel(cPathScript)==1;
	cPathScript		= repto(cPathScript,sScript);
	
	if bSingleScript
		bAppendScript		= true(sScript);
		bAppendScript(1)	= opt.script_append(1);
		bBackupScript		= false(sScript);
		bBackupScript(1)	= opt.backup;
	else
		bAppendScript	= repto(opt.script_append,sScript);
		bBackupScript	= repto(opt.backup,sScript);
	end
	
	cPathLog	= ForceCell(opt.log_path);
	cPathLog	= cellfun(@(fl) conditional(isdir(fl),PathUnsplit(fl,opt.file_prefix,'log'),fl),cPathLog,'UniformOutput',false);
	bSingleLog	= numel(cPathLog)==1;
	cPathLog	= repto(cPathLog,sScript);
	
	if bSingleLog
		bAppendLog		= true(sScript);
		bAppendLog(1)	= opt.log_append(1);
		bBackupLog		= false(sScript);
		bBackupLog(1)	= opt.backup;
	else
		bAppendLog	= repto(opt.log_append,sScript);
		bBackupLog	= repto(opt.backup,sScript);
	end
%get temporary paths for scripts and logs
	cPathScriptTemp	= cellfun(@(x) GetTempFile,cPathScript,'UniformOutput',false);
	cPathLogTemp	= cellfun(@(x) GetTempFile,cPathLog,'UniformOutput',false);
%save the scripts and make them executable
	for kS=1:nScript
		if opt.debug
			disp('-------');
			disp(cScript{kS});
			disp('-------');
		end
		
		if ~fput(cScript{kS},cPathScriptTemp{kS})
			error(['The script "' cPathScriptTemp{kS} '" could not be saved.']);
		end
		if system(['chmod 777 ' cPathScriptTemp{kS}])
			error(['Execute privileges could not be added to "' cPathScriptTemp{kS} '".']);
		end
	end
%save metascript so environment variables and logs will work correctly
	cPathMetaScript	= cellfun(@(x) GetTempFile,cPathScript,'UniformOutput',false);
	
	for kS=1:nScript
		cMetaScript		=	{
								'#!/bin/bash -i'										%create an interactive shell
								'unset LD_LIBRARY_PATH'								%FSL commands get screwed up with MATLAB's libraries on LD_LIBRARY_PATH
								'source ${FSLDIR}/etc/fslconf/fsl.sh > /dev/null'		%make sure FSL is ready to roll
								[cPathScriptTemp{kS} ' 2>&1 | tee ' cPathLogTemp{kS}]	%save the stdout and stderr to a file
								'exit ${PIPESTATUS[0]}'								%exit with the script's exit code rather than tee's
							};
							
		strMetaScript	= join(cMetaScript,10);
		
		if ~fput(strMetaScript,cPathMetaScript{kS})
			error(['The meta-script "' cPathMetaScript{kS} '" could not be saved.']);
		end
		if system(['chmod 777 ' cPathMetaScript{kS}])
			error(['Execute privileges could not be added to the meta-script "' cPathMetaScript{kS} '".']);
		end
	end
%execute the scripts
	vExitCode	= NaN(sScript);
	cOutput		= cell(sScript);
	
	if opt.run
		if opt.cores==1
			if ~opt.silent
				progress('action','init','total',nScript,'label',opt.description,'status',true,'silent',opt.silent);
			end
			for kS=1:nScript
				[vExitCode(kS),cOutput{kS}]	= RunOne(cPathMetaScript{kS},cPathLogTemp{kS},opt);
				
				if ~opt.silent
					progress;
				end
			end
		else
			[vExitCode,cOutput]	= MultiTask(@RunOne,{cPathMetaScript, cPathLogTemp, opt},...
									'cores'			, opt.cores			, ...
									'description'	, opt.description	, ...
									'silent'		, opt.silent		  ...
									);
			vExitCode			= cell2mat(vExitCode);
		end
	end
%copy the scripts and logs
	for kS=1:nScript
		if ~isempty(cPathScript{kS})
			if bBackupScript(kS) && ~bAppendScript(kS) && FileExists(cPathScript{kS}) && ~backup(cPathScript{kS})
				error(['Could not backup existing script file "' cPathScript{kS} '".']);
			end
			
			fput([conditional(bAppendScript(kS),10,'') reshape(cScript{kS},1,[])],cPathScript{kS},'append',bAppendScript(kS));
		end
		
		if ~isempty(cPathLog{kS})
			strLog	= fget(cPathLogTemp{kS});
			
			if bBackupLog(kS) && ~bAppendLog(kS) && FileExists(cPathLog{kS}) && ~backup(cPathLog{kS})
				error(['Could not backup existing log file "' cPathLog{kS} '".']);
			end
			
			fput([conditional(bAppendLog(kS),10,'') strLog],cPathLog{kS},'append',bAppendLog(kS));
		end
	end
%delete temporary files
	cellfun(@delete,cPathScriptTemp);
	
	if opt.run
		cellfun(@delete,cPathLogTemp);
	end
	
	cellfun(@delete,cPathMetaScript);
%parse the output
	if bCharOutput
		cOutput	= cOutput{1};
	end

%------------------------------------------------------------------------------%
function [vExitCode,strOutput] = RunOne(strPathMetaScript,strPathLog,opt)
	setenv('cmd',strPathMetaScript);
	
	cEcho					= conditional(opt.silent,{},{'-echo'});
	[vExitCode,strOutput]	= system(['$cmd' conditional(opt.wait,'',' &')],cEcho{:});
	
	try
		strOutput	= fget(strPathLog);
	catch me
		strOutput	= '';
	end
%------------------------------------------------------------------------------%
