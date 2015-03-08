function gc = GrangerCausality(src,dst,varargin)
% GrangerCausality
% 
% Description:	compute the multivariate granger causality from one signal to
%				another
% 
% Syntax:	gc = GrangerCausality(src,dst,<options>)
% 
% In:
% 	src	- an nSample x ndSrc array of source data
%	dst	- an nSample x ndDst array of destination data
%	<options>:
%		lag:		(1) an array specifying the lags to use in the GC
%					calculation. e.g. [1 2 4] will include the 1st, 2nd, and 4th
%					lagged signals.
%		samples:	(<all>) the samples to consider in the computation. these
%					samples define the 'next' signal in the regression.
%		max_aclags:	(1000) bound on autocov lags to limit running time.
% 
% Out:
% 	gc	- the multivariate granger causality from src to dst
%
% Notes:
%	algorithm taken from the MVGC toolbox by Lionel Barnett and Anil Seth.
%	see http://www.sussex.ac.uk/Users/lionelb/MVGC/html/mvgchelp.html.
%
% Example:
% n				= 100;
% nd			= 1;
% noise			= 0.01:0.01:1;
% nNoise		= numel(noise);
% [gc,gcu,te]	= deal(NaN(nNoise,1));
% for kN=1:nNoise
% 	X		= randn(n,nd);
% 	Y		= [randn(1,nd); X(1:end-1,:)] + noise(kN)*randn(size(X));
% 	gc(kN) 	= GrangerCausality(X,Y);
% 	gcu(kN)	= GrangerCausalityUni(X,Y);
% 	te(kN)	= TransferEntropy(X,Y);
% end
% h	= alexplot(noise,{gc gcu te},...
% 		'legend'	, {'GC','GCu','TE'}	  ...
% 		);
% 
% Updated: 2015-02-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dbg	= struct;

opt	= ParseArgs(varargin,...
		'lag'			, 1		, ...
		'samples'		, []	, ...
		'max_aclags'	, 1000	  ...
		);

[nSample,ndSrc]		= size(src);
[nSampleDst,ndDst]	= size(dst);

if nSample ~= nSampleDst
	error('Source and destination data must have the same number of data samples.');
end

%extract the samples of interest
	%get the samples to include
		maxLag	= max(opt.lag);
		nLag	= numel(opt.lag);
		
		kStartNext	= maxLag + 1;
		kEndNext	= nSample;
		
		if isempty(opt.samples)
			kSampleNext	= kStartNext:kEndNext;
		else
			kSampleNext	= opt.samples(opt.samples>=kStartNext & opt.samples<=kEndNext);
			kSampleNext	= reshape(kSampleNext,1,[]);
		end
	%demean the data that will be used
		kSampleMin			= min(kSampleNext);
		kSampleAll			= [kSampleMin-maxLag:kSampleMin-1 kSampleNext];
		src(kSampleAll,:)	= demean(src(kSampleAll,:),1);
		dst(kSampleAll,:)	= demean(dst(kSampleAll,:),1);
	
	%construct past and next signals
		srcPast	= ConstructPasts(src,opt.lag,kSampleNext);
		srcNext	= ConstructPast(src,0,kSampleNext);
		dstPast	= ConstructPasts(dst,opt.lag,kSampleNext);
		dstNext	= ConstructPast(dst,0,kSampleNext);

%fit a VAR model to the data
	[A,SIG]	= FitVARModel(srcPast,srcNext,dstPast,dstNext);

%calculate the autocovariance sequence for the model
	G	= Var2AutoCov(A,SIG,nLag,opt.max_aclags);

%calculate the MVGC
	gc	= CalcMVGC(G,ndSrc,ndDst);

%------------------------------------------------------------------------------%
function xPast = ConstructPasts(x,lags,kSampleNext)
%construct the set of past (lagged) signals. output is nSample x nLag.
	xPast	= arrayfun(@(lag) ConstructPast(x,lag,kSampleNext),lags,'uni',false);
	xPast	= cat(2,xPast{:});

%------------------------------------------------------------------------------%
function xPast = ConstructPast(x,lag,kSampleNext)
%construct a single past signal
	xPast	= x(kSampleNext - lag,:);

%------------------------------------------------------------------------------%
function X = lyapslv(A,Q)
% modified from mvgc/utils/control/lyapslv.m
	n	= size(A,1);
	
	%Schur factorisation
		[U,T]	= schur(A);
		Q		= -U'*Q*U;
	
	%solve the equation column ~by column
		X	= zeros(n);
		j	= n;
		while j>0
			j1	= j;
		
			%check Schur block size
				if j~=1 && T(j,j-1)~=0
					bsiz = 2;
					j = j-1;
				else
					bsiz = 1;
				end
				bsizn	= bsiz*n;
		
			Ajj	= kron(T(j:j1,j:j1),T) - eye(bsizn);
		
			rhs	= reshape(Q(:,j:j1),bsizn,1);
		
			if j1<n
				rhs	= rhs + reshape(T*(X(:,j1+1:n)*T(j:j1,j1+1:n)'),bsizn,1);
			end
		
			v		= -Ajj\rhs;
			X(:,j)	= v(1:n);
		
			if bsiz==2
				X(:,j1)	= v(n+1:bsizn);
			end
		
			j = j-1;
		end
	
	%transform back to original coordinates
		X	= U*X*U';

%------------------------------------------------------------------------------%
function [A,SIG] = FitVARModel(srcPast,srcNext,dstPast,dstNext)
% modified from tsdata_to_var in the MVGC toolbox
	nSample	= size(srcPast,1);
	
	%transpose the signals here since we are using nSample x nd signals and the
	%MVGC toolbox expects nd x nSample signals. also for some reason Seth puts
	%destination signals before source signals (annoying)
	
	xNext	= [dstNext srcNext]';
	xPast	= [dstPast srcPast]';
	
	A	= xNext/xPast;
	err	= xNext - A*xPast;
	
	%how is this different from cov(err,1)?
	SIG	= err*err'/(nSample-1);

%------------------------------------------------------------------------------%
function G = Var2AutoCov(A,SIG,nLag,maxACLags)
% modified from var_to_autocov in the MVGC toolbox
	[n,pn]	= size(A);
	p		= nLag;
	pn1		= (p-1)*n;
	
	A1		= [A; eye(pn1) zeros(pn1,n)];
	SIG1	= [SIG zeros(n,pn1); zeros(pn1,n) zeros(pn1)];
	G1		= lyapslv(A1,-SIG1);
	
	acdectol	= 1e-8;
	rho			= max(abs(eig(A1)));
	aclags		= ceil(log(acdectol)/log(rho)); % minimum lags to achieve specified tolerance
	
	q	= max(p,min(aclags,maxACLags));
	q1	= q+1;
	
	G	= cat(3,reshape(G1(1:n,:),n,n,p),zeros(n,n,q1-p));	%autocov forward  sequence
	B	= [zeros((q1-p)*n,n); G1(:,end-n+1:end)];	%autocov backward sequence
	A	= reshape(A,n,pn);	%coefficients
	for k = p:q
		r					= q1-k;
		rn					= r*n;
		G(:,:,k+1)			= A*B(rn+1:rn+pn,:);
		B((r-1)*n+1:rn,:)	= G(:,:,k+1);
	end

%------------------------------------------------------------------------------%
function [A,SIG] = AutoCov2Var(G)
% modified from autocov_to_var in the MVGC toolbox
	[n,~,q1]	= size(G);
	q			= q1-1;
	qn			= q*n;
	
	G0	= G(:,:,1);	%covariance
	GF	= reshape(G(:,:,2:end),n,qn)';	%forward  autocov sequence
	GB	= reshape(permute(flipdim(G(:,:,2:end),3),[1 3 2]),qn,n);	%backward autocov sequence
	
	%forward and backward coefficients
		[AF,AB]	= deal(zeros(n,qn));
	
	%initialise recursion
		k	= 1; %model order
		kn	= k*n;
		
		r	= q-k;
		rn	= r*n;
		kf	= 1:kn;		%forward  indices
		kb	= rn+1:qn;	%backward indices
		
		AF(:,kf)	= GB(kb,:)/G0;
		AB(:,kb)	= GF(kf,:)/G0;
	
	for k=2:q
		kn	= k*n;
		
		kB1	= (r-1)*n+1:rn;
		kF1	= (k-1)*n+1:kn;
		
		GB1	= GB(kB1,:);
		GB2	= GB(kb,:);
		
		GF1	= GF(kF1,:);
		GF2	= GF(kf,:);
		
		AF1	= AF(:,kf);
		AB1	= AB(:,kb);
		
		AAF	= (GB1 - AF1*GB2)/(G0 - AB1*GB2); %DF/VB
		AAB	= (GF1 - AB1*GF2)/(G0 - AF1*GF2); %DB/VF
	
		r	= q-k;
		rn	= r*n;
		kf	= 1:kn;
		kb	= rn+1:qn;
		
		AF(:,kf)	= [AF1-AAF*AB1 AAF];
		AB(:,kb)	= [AAB AB1-AAB*AF1];
	end
	
	SIG	= G0 - AF*GF;
	A	= reshape(AF,n,n,q);

%------------------------------------------------------------------------------%
function gc = CalcMVGC(G,ndSrc,ndDst)
% modified from autocov_to_mvgc in the MVGC toolbox
	x	= 1:ndSrc;
	y	= ndSrc+1:ndSrc+ndDst;
	xy	= [x y];
	
	%full and reduced regressions
		[~,SIG]		= AutoCov2Var(G(xy,xy,:));
		[~,SIGR]	= AutoCov2Var(G(x,x,:));
	
	x			= 1:numel(x);
	detSIGR		= det(SIGR(x,x));
	detSIG		= det(SIG(x,x));
	if detSIGR <= 0 || detSIG <= 0
		gc		= 0;
	else
		gc		= log(detSIGR) - log(detSIG);
	end

%------------------------------------------------------------------------------%
