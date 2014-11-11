function sshmount(varargin)
% sshmount
% 
% Description:	mount a remove folder using ssh
% 
% Syntax:	sshmount(
%				'user'			, strUser		, ...
%				'host'			, strHost		, ...
%				'remote_dir'	, strDirRemote	, ...
%				'local_dir'		, strDirLocal	  ...
%			);
% 
% In:
% 	strUser			- the remote user name
%	strHost			- the remote host
%	strDirRemote	- the remote folder to mount
%	strDirLocal		- the local folder in which to mount it
% 
% Updated: 2014-01-20
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'user'			, []	, ...
		'host'			, []	, ...
		'remote_dir'	, []	, ...
		'local_dir'		, []	  ...
		);

%check the inputs
	cOpt	= fieldnames(opt);
	nOpt	= numel(cOpt);
	
	for kO=1:nOpt
		if isempty(opt.(cOpt{kO}))
			error([cOpt{kO} ' was not specified.']);
		end
	end

%make sure we have the correct commands
	cCommandCheck	= {'sshfs'};
	cellfun(@(cmd) syswhich(cmd,'error',true), cCommandCheck, 'uni', false);

%make sure the local folder exists
	CreateDirPath(opt.local_dir,'error',true);

%mount!
	strCommand	= sprintf('sshfs %s@%s:%s %s',...
					opt.user		, ...
					opt.host		, ...
					opt.remote_dir	, ...
					opt.local_dir	  ...
					);
	
	[ec,out]	= RunBashScript(strCommand);

%error?
	if ec
		error(['mount was unsuccessful (' StringTrim(out) ')']);
	end
