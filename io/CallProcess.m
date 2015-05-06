function [vExitCode,cOutput] = CallProcess(strCommand,varargin)
% CallProcess
% 
% Description:	call a system command with the specified sets of inputs
% 
% Syntax:	[vExitCode,cOutput] = CallProcess(strCommand,[cIn]=<none>,<options>) OR
%			cScript = CallProcess(strCommand,[cIn]=<none>,'run',false,<options>)
% 
% In:
% 	strCommand	- the system command
%	cIn			- a cell of input arguments for nCall calls to the specified
%				  command.  each entry of cIn is either an nCall-length cell or
%				  a value that will be passed as the corresponding input
%				  argument to each call.  all values are converted to strings
%				  and arguments containing spaces are enclosed in quotes if they
%				  aren't already or if the contain double quotes.  double quotes
%				  are escaped unless they enclose the argument.
%	<options>:
%		description:	(['Calling ' strCommand]) a description of the process
%		file_prefix:	('<strCommand>-callprocess') the prefix to use when
%						constructing script/log paths from directories
%		script_path:	(<don't save>) either the path to which to save the
%						script used to execute each system call, or an
%						nCall-length cell of paths to save each call's script
%						separately.  if a directory is passed, the script file
%						name is <file_prefix>.sh
%		script_append:	(false) true to append the current script to the script
%						file if it already exists, false to overwrite it
%		log_path:		(<don't save>) either the path to which to save the
%						output from all calls, or a cell of paths to save each
%						call's script output separately.  if a directory is
%						passed, the log file name is <file_prefix>.log
%		log_append:		(false) true to append the log file if it already
%						exists, false to overwrite it
%		backup:			(true) true to backup existing script or log files
%						before overwriting them
%		run:			(true) true to actually execute the script
%		wait:			(true) true to wait for script execution to finish
%						before returning.  note that logs won't be deleted
%						properly and no status will be returned if this is false
%		debug:			(false) true to display the commands that are called
%		cores:			(1) the number of processor cores to use
%		silent:			(false) true to suppress the script output from the
%						MATLAB window
% 
% Out:
% 	vExitCode	- an array of exit codes, one entry for each call to the command
%	cOutput		- a cell of the command outputs
%	cScript		- a cell of scripts that would have been called
% 
% Updated: 2015-05-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[cIn,opt]	= ParseArgs(varargin,[],...
				'description'		, ['Calling ' strCommand]		, ...
				'file_prefix'		, [strCommand '-callprocess']	, ...
				'script_path'		, []							, ...
				'script_append'		, false							, ...
				'log_path'			, []							, ...
				'log_append'		, false							, ...
				'backup'			, true							, ...
				'run'				, true							, ...
				'wait'				, true							, ...
				'debug'				, false							, ...
				'cores'				, 1								, ...
				'silent'			, false							  ...
				);

%format the input arguments
	if ~isempty(cIn)
		[cIn{:}]	= ForceCell(cIn{:});
		[cIn{:}]	= FillSingletonArrays(cIn{:});
		
		if any(cellfun(@numel,cIn) == 0)
			[vExitCode,cOutput]	= deal([]);
			return;
		end
	else
		cIn		= {{[]}};
	end
	
	cIn	= cellfun(@(ci) cellfun(@EscapeArgument,ci,'UniformOutput',false),cIn,'UniformOutput',false);
%construct each script
	cScript	= cellfun(@(varargin) join([strCommand cellfun(@(v) tostring(v),varargin,'UniformOutput',false)],' '),cIn{:},'UniformOutput',false);
%run each script
	cOpt				= opt2cell(opt);
	[vExitCode,cOutput]	= RunBashScript(cScript,cOpt{:});
	
	if ~opt.run
		vExitCode	= cScript;
	end
