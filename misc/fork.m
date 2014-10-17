function h = fork(f,varargin)
% fork
% 
% Description:	fork a function
% 
% Syntax:	h = fork(f,[cIn]={},<options>)
% 
% In:
% 	f	- a function handle
%	cIn	- a cell of input arguments.
%	<options>:
%		delay:	(0.01) the number of seconds to wait before executing the
%				function
%		nout:	(<auto>) the number of outputs from the function
% 
% Out:
% 	h	- the handle to an object to pass to forkOutput to retrieve the outputs
% 
% Updated: 2012-07-18
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[cIn,opt]	= ParseArgs(varargin,{},...
				'delay'	, 0.01	, ...
				'nout'	, []	  ...
				);

opt.nout	= unless(opt.nout,nargout(f));

h	= timer(...
		'TimerFcn'		, @TimerFunction	, ...
		'StartDelay'	, opt.delay			  ...
		);

start(h);

%------------------------------------------------------------------------------%
function TimerFunction(tmr,fTmr)
	cOut	= cell(opt.nout,1);
	
	[cOut{1:opt.nout}]	= f(cIn{:});
	
	set(tmr,'UserData',cOut);
	
	if opt.nout<=0
		stop(tmr);
		delete(tmr);
	end
end
%------------------------------------------------------------------------------%

end
