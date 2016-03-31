function [xMatch,yMatch,sMatch] = SignalMatch(x,y,varargin)
% SignalMatch
% 
% Description:	find the best match between two sets of signals
% 
% Syntax:	[xMatch,yMatch,sMatch] = SignalMatch(x,y,<options>)
% 
% In:
% 	x	- an nSample x nSignal array of signals
%	y	- another nSample x nSignal array of signals
%	<options>:
%		anticorrelated:	(true) true to allow anticorrelated signals to count as
%						matches. anticorrelated signals are flipped so they
%						become positively correlated.
%		chunk:			([]) an nSample x 1 array specifying the chunk to which
%						each sample belongs. if specified, then matching will be
%						performed independently for each chunk, leaving data for
%						that chunk out of the calculation to avoid artificially
%						inflating the correspondence between signals. in this
%						case, the output signals are piecewise composites of
%						(across chunks) the input signals.
%		max_recursion:	(1000) the maximum recursion limit
%		silent:			(true) true to suppress status messages
% 
% Out:
% 	xMatch	- the reordered set of x signals (i.e. x(:,k) matches y(:,k))
%	yMatch	- the reordered set of y signals
%	sMatch	- a struct of info about the match process
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse inputs
	opt	= ParseArgs(varargin,...
			'anticorrelated'	, true	, ...
			'chunk'				, []	, ...
			'max_recursion'		, 1000	, ...
			'silent'			, true	  ...
			);
	
	[nSample,nSignal]	= size(x);
	
	bChunk	= ~isempty(opt.chunk);
	if ~bChunk
		opt.chunk	= ones(nSample,1);
	end

%align each chunk
	chunks	= unique(opt.chunk);
	nChunk	= numel(chunks);
	
	xMatch	= x;
	yMatch	= NaN(nSample,nSignal);
	
	progress('action','init','total',nChunk,'label','Processing each chunk','silent',opt.silent);
	for kC=1:nChunk
		chunk	= chunks(kC);
		
		%get the chunk's complement
			bChunk		= opt.chunk==chunk;
			bComplement	= ~bChunk;
			
			if ~any(bComplement)
				%no chunks specified
				bComplement	= bChunk;
			end
			
			xComp	= x(bComplement,:);
			yComp	= y(bComplement,:);
		%calculate the distance between each pair of signals
			D				= pdist2(xComp',yComp','correlation');
			s.D				= D;
		%make negative correlations positive, and mark them for negating if they
		%end up being matches
			if opt.anticorrelated
				bNeg	= D>1;
				D(bNeg)	= 2-D(bNeg); %1 - (-(1 - D))
				
				%anything negative is just due to floating point error
					D(D<0)	= 0;
			else
				bNeg	= false(size(D));
			end
		%minimize the correlation distances
			try
				kY2X	= mintrace(D);
			catch me
				if isequal(me.identifier,'MATLAB:recursionLimit')
					status('Recursion limit reached.  Increasing to maximum limit.','warning',true,'silent',opt.silent);
					
					rlOld	= get(0,'RecursionLimit');
					set(0,'RecursionLimit',opt.max_recursion);
					kY2X	= mintrace(D);
					set(0,'RecursionLimit',rlOld);
				else
					rethrow(me);
				end
			end
			s.idx_y2x	= kY2X;
			
			kX2Y		= zeros(nSignal,1);
			kX2Y(kY2X)	= 1:nSignal;
			s.idx_x2y	= kX2Y;
		%match up y with x
			yMatch(bChunk,:)	= y(bChunk,kY2X);
		%negate the components with negative correlations
			
			bNeg	= bNeg(:,kY2X);
			bDiag	= logical(eye(nSignal));
			kNeg	= find(bNeg(bDiag));
			
			bNeg				= false(nSignal,1);
			bNeg(kNeg)			= true;
			s.negate			= bNeg;
			
			s.negate_orig	= s.negate(s.idx_x2y);
			
			yMatch(bChunk,kNeg)	= -yMatch(bChunk,kNeg);
		
		if kC==1
			sMatch	= s;
		else
			sMatch(end+1)	= s;
		end
		
		progress;
	end
