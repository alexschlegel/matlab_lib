function varargout = regressMulti(y,x,varargin)
% regressMulti
% 
% Description:	like regress, but y is an n1 x n2 x ... x nK x N array of
%				(n1*n2*...*nK) independent sets of N observations, and the
%				outputs are n1 x n2 x ... x nK x (m1 x ... x mJ) arrays
% 
% Syntax:	[b,bint,r,rint,stats] = regressMulti(y,x,[alpha]=0.05,<options>)
%
% In:
%	(see regress)
%	<options>:
%		nper:		(1000) the number of regressions to perform per iteration
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
%
% Out:
%	(see regress)
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[alpha,opt]	= ParseArgs(varargin,0.05,...
				'nper'		, 1000	, ...
				'cores'		, 1		, ...
				'silent'	, false	  ...
				);

%did we get a regular regress call?
	sY	= size(y);
	
	if numel(sY)==2 && sY(2)==1
		[varargout{1:nargout}]	= regress(y,x,alpha);
		return;
	end
%break y up into blocks
	y		= reshape(y,[],sY(end));
	nSet	= size(y,1);
	
	nBlockWhole	= floor(nSet/opt.nper);
	nSetWhole	= nBlockWhole.*opt.nper;
	
	sBlock	= repmat(opt.nper,[nBlockWhole 1]);
	
	if nSet~=nSetWhole
		sBlock	= [sBlock; nSet-nSetWhole];
		nBlock	= nBlockWhole+1;
	else
		nBlock	= nBlockWhole;
	end
	
	y	= mat2cell(y,sBlock,sY(end));
%regress each block
	[varargout{1:nargout}]	= MultiTask(@DoRegress,{y x alpha},...
								'description'	, 'fitting regression weights'	, ...
								'silent'		, opt.silent					, ...
								'twait'			, 500							, ...
								'cores'			, opt.cores						, ...
								'uniformoutput'	, false							  ...
								);
%concatenate and reshape the outputs
	sOut		= cellfun(@(v) size(v{1}),varargout,'UniformOutput',false);
	varargout	= cellfun(@(x,s) reshape(cat(1,x{:}),[sY(1:end-1) s(2:end)]),varargout,sOut,'UniformOutput',false);

%------------------------------------------------------------------------------%
function varargout = DoRegress(y,x,alpha)
	warning('off','stats:regress:NoConst');
	
	nOut	= nargout;
	nY		= size(y,1);
	
	cOut	= cell(nY,nOut);
	
	for kY=1:nY
		[cOut{kY,1:nOut}]	= regress(y(kY,:)',x,alpha);
	end
	
	cOut	= arrayfun(@(k) cat(3,cOut{:,k}),(1:nOut)','UniformOutput',false);
	cOut	= cellfun(@(x) permute(x,[3 1 2]),cOut,'UniformOutput',false);
	
	varargout	= cOut;
%------------------------------------------------------------------------------%
