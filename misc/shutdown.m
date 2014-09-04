function shutdown(varargin)
% shutdown
% 
% Description:	shutdown the computer
% 
% Syntax:	shutdown(<options>)
% 
% In:
% 	<options>:
%		'prompt':	(true) true to prompt before shutting down
%		'delay':	(0) delay before shutdown, in seconds
% 
% Updated:	2010-09-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin, ...
		'prompt'	, true	, ...
		'delay'		, 0		  ...
		);
opt.delay	= round(max(0,opt.delay));
strDelay	= num2str(opt.delay);

%prompt before shutdown		
	if opt.prompt
		if opt.delay>0
			strPromptDelay	= ['in ' strDelay ' seconds'];
		else
			strPromptDelay	= 'now';
		end
		res	= ask(['Shutdown ' strPromptDelay '?'],'title',mfilename,'choice',{'Yes','No'},'default','No');
		
		if isempty(res) || isequal(res,'No')
			status('Shutdown aborted');
			return;
		end
	end

%issue the command
	if ispc
		dos(['shutdown /s /f /t ' strDelay]);
 	elseif isunix
		if opt.delay>0
			strCommandDelay	= ['-t ' strDelay];
		else
			strCommandDelay	= 'now';
		end
		
		unix(['shutdown -h ' strCommandDelay]);
	else
		error('Shutdown not supported on this system');
	end
