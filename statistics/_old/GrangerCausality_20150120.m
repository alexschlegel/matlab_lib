function gc = GrangerCausality(src,dst,varargin)
% GrangerCausality
% 
% Description:	compute the granger causality from one signal to another
% 
% Syntax:	gc = GrangerCausality(src,dst,<options>)
% 
% In:
% 	src	- an nSample x 1 source signal
%	dst	- an nSample x 1 destination signal
%	<options>:
%		history:		(1) the lag value for the GC calculation (ONLY 1 IS
%						SUPPORTED)
%		signal_block:	(<none>) this is a hack for gridop because my "signals"
%						are actually blocks of 5 samples (one block for each
%						trial) smooshed together, so that comparing the 5th
%						sample of the source to the 5th and 6th samples of the
%						destination (i.e. past to past & next) is meaningless,
%						since the 6th sample is actually the 1st sample of the
%						next, totally unrelated trial. in this case,
%						signal_block:=5.
% 
% Out:
% 	gc	- the granger causality from src to dest
%
% Notes:
%	algorithm taken from the GCCAtoolbox by Anil Seth
%
% Example:
%	n=200; blk=5;
%	x = randn(n,1); y=[0; x(1:end-1)];
%	kb=[]; for k=1:n/(2*blk), kb=[kb; 2*blk*(k-1) + (1:blk)']; end
%	xs=x(1:n/2); ys=y(1:n/2); xb = x(kb); yb=y(kb);
%	gcFull = GrangerCausality(xb,yb);
%	gcBlock = GrangerCausality(xb,yb,'signal_block',blk);
%	gcCompare = GrangerCausality(xs,ys);
% 
% Updated: 2014-03-28
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'history'		, 1		, ...
		'signal_block'	, []	  ...
		);

if opt.history~=1
	error('Only history value of 1 is supported.');
end

%remove the signal means
	[src,dst]	= varfun(@(x) x - mean(x),src,dst);

%signal subsets
	sPast	= src(1:end-1);
	dPast	= dst(1:end-1);
	dNext	= dst(2:end);

%optionally remove the block border samples (see documentation)
	if ~isempty(opt.signal_block)
		nSample	= numel(src);
		kSkip	= opt.signal_block:opt.signal_block:nSample-1;
		
		sPast(kSkip,:)	= [];
		dPast(kSkip,:)	= [];
		dNext(kSkip,:)	= [];
	end

%granger causality
	C	= RegCov([sPast dPast],dNext);
	S	= RegCov(dPast,dNext);
	
	gc	= log(S/C);

%------------------------------------------------------------------------------%
function C = RegCov(reg,d)
%perform linear regression on d using the predictors in reg and return the
%covariance of the residual
	beta	= reg\d;
	err		= d - reg*beta;
	C		= cov(err,1);
%------------------------------------------------------------------------------%
