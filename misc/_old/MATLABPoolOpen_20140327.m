function [bSuccess,nThread,bOpened] = MATLABPoolOpen(nThread,varargin)
% MATLABPoolOpen
% 
% Description:	open a matlab pool for parallel processing
% 
% Syntax:	[bSuccess,nThread,bOpened] = MATLABPoolOpen(nThread,<options>)
% 
% In:
% 	nThread	- the number of threads to use
%	<options>:
%		ntask:	([]) the number of tasks that the pool will perform. if 1, then
%				the pool won't be opened.
%		origin:	('abs') either 'abs' or 'rel' to specify whether nThread is
%				absolute or relative to the maximum number of threads
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- true if the pool was successfully opened or the pool was
%				  already open
%	nThread		- the number of threads in the pool
%	bOpened		- true if the pool was actually opened
% 
% Updated: 2014-03-03
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'ntask'		, []	, ...
		'origin'	, 'abs'	, ...
		'silent'	, false	  ...
		);


%get the number of threads to use
	nMax	= GetNumCores;
	switch lower(opt.origin)
		case 'abs'
		case 'rel'
			nThread	= nMax + nThread;
		otherwise
			error('"%s" is not a valid origin.',tostring(opt.origin));
	end
	
	nThread	= max(1,min(nMax,nThread));

[bSuccess,bOpened]	= deal(false);

if nThread>1 && (isempty(opt.ntask) || opt.ntask>1)
	%get the cluster object to use
		cluster		= parcluster;
		bWrongSize	= get(cluster,'NumWorkers')<nThread;
		if bWrongSize
			if ~MATLABPoolClose('silent',opt.silent)
				return;
			end
			
			set(cluster,'NumWorkers',nThread)
		end
	
	%open the pool
		if bWrongSize
			bOpen	= true;
		else
			bOpen	= matlabpool('size') ~= nThread;
		end
		
		if bOpen
			try
				if opt.silent
					evalc('matlabpool(cluster, nThread);');
				else
					matlabpool(cluster, nThread);
				end
				
				[bSuccess,bOpened]	= deal(true);
			catch me
				return;
			end
		else
		%already open
			bSuccess	= true;
		end
		
		nThread	= matlabpool('size');
else
%don't need to open
	bSuccess	= true;
end
