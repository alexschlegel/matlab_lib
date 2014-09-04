function [t,f,varargout] = GetTParameter(n,varargin)
% GetTParameter
% 
% Description:	construct a t parameter
% 
% Syntax:	[t,f,[p1,...,pN]] = GetTParameter(n,[f]='linear',[p1,...,pN]=<see below>) OR
%			[t,f,p] = GetTParameter(n,[f]='linear',p) OR
%			f = GetTParameter('query')
% 
% In:
%	n		- the number of steps
% 	[f]		- a cfit or inline function of 'x' with domain [0,1] and range
%			  [0,1], or one of the following strings denoting a built-in
%			  function:
%				'linear':	linear (p1*x+p2) ({pK}={1,0})
%				'exp':		exponential (p2*exp(p1*x)+p3) ({pK}={1,1,0})
%				'poly':		polynomial (sum(p(2K)*x^p(2K-1))) ({pK}={1,1})
%				'interp':	interpolate from control points. p(2K-1) is the 
%							position and p(2K) is the value
%	[pK]	- the value of the Kth parameter to the chosen function
%	p		- a cell of parameters of f
% 
% Out:
% 	t		- the t parameter, based on the specified step function
%	f		- the actual step function used as an inline function object
%	[pK]	- the actual value of the kth parameter of f used to construct t
%	p		- a cell of the actual parameters of f used to construct t
%
% Note:
%	If the parameters specified lead to values outside the range [0,1], the
%	results are translated and scaled to [0,1].  The parameters required to
%	do this are added to the output f and pK's.
% 
% Example:	GetTParameter(5,'linear') = [0 0.25 0.5 0.75 1]
% 
% Updated:	2009-01-06
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[f,p]	= ParseArgs(varargin,'linear');

%get the input to the step function
	x	= reshape(GetInterval(0,1,n),[],1);
	
%get the step function
	switch class(f)
		case 'char'
			switch lower(f)
				case 'linear'
					pDef	= {1 0};
					nP		= numel(pDef);
					f		= inline('P1.*x+P2',nP);
				case 'exp'
					pDef	= {1 1 0};
					nP		= numel(pDef);
					f		= inline('P2.*exp(P1.*x)+P3',nP);
				case 'poly'
					nP		= min(2,2*ceil(numel(p)/2));
					pDef	= repmat({1},[1 nP]);
					f		= inline(GetPolyString(nP),nP);
				case 'interp'
					xC	= cell2mat(reshape(p(1:2:end),[],1));
					yC	= cell2mat(reshape(p(2:2:end),[],1));
					
					nP		= 0;
					f		= fit(xC,yC,'pchipinterp');
					pDef	= {};
					
					p	= {};
				otherwise
					error('GetTParameter:unrecognized_builtin_function',['''' f ''' is not a recognized built-in function.']);
			end
		case 'inline'
			f		= vectorize(f);
			nP		= numel(p);
			pDef	= p;
		case 'cfit'
			nP		= 0;
			pDef	= {};
	end
	
%fill empty parameters
	p	= FillParams(p,pDef);
		
%get the t parameter
	t	= feval(f,x,p{:});
	
%scale the parameter if necessary
	strF	= formula(f);
	bInterp	= isequal(strF,'piecewise polynomial');
	
	bMod	= false;
	if any(t<0)
		bMod	= true;
		pMod	= min(t);
		
		if ~bInterp
			nP		= nP+1;
			
			strPAdd	= ['P' num2str(nP)];
			strF	= [strF '+' strPAdd];
			
			p	= [p;{pMod}];
		end
		
		t	= t - pMod;
	end
	
	if any(t>1)
		bMod	= true;
		pMod	= 1/max(t);
		
		if ~bInterp
			nP		= nP+1;
		
			strPAdd	= ['P' num2str(nP)];
			strF	= [strPAdd '*(' strF ')'];
		
			p	= [p;{pMod}];
		end
		
		t	= pMod*t;
	end

%get the outputs
	if bMod
		if bInterp
			f	= fit(x,t,'pchipinterp');
		else
			f	= inline(strF,nP);
		end
	end
	
	if nargout==3
		varargout{1}	= p;
	else
		varargout		= p;
	end


%------------------------------------------------------------------------------%
function p = FillParams(p,pDef)
%fill the unspecified elements of p with elements of pDef
	nP	= numel(p);
	nT	= numel(pDef);
	
	p(nP+1:nT)	= pDef(nP+1:nT);
	p			= reshape(p(1:nT),[],1);
%------------------------------------------------------------------------------%
function str = GetPolyString(n)
%assumes 2|n
	cStr	= cell(1,n/2);
	
	for k=1:n/2
		strP1	= ['P' num2str(2*k-1)];
		strP2	= ['P' num2str(2*k)];
		
		cStr{k}	= [strP2 '.*x.^' strP1];
	end
	
	str	= join(cStr,'+');
%------------------------------------------------------------------------------%
