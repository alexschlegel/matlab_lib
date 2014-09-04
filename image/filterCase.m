function M = filterCase(M,kC,cF,varargin)
% FILTERCASE
% 
% Description:	filters the elements of M, using a different filter depending
%				on the corresponding values of kC
% 
% Syntax:	M = filterCase(M,kC,cF,[pMethod]='zeros')
%
% In:
%	M			- the matrix to filter
%	kC			- an index matrix the same size as M corresponding to filter
%				  in cF
%	cF			- a cell of filters
%	[pMethod]	- the padding method.  can be 'zeros', 'replicate', 'circular',
%				  'symmetric' or 'linear' to do linear extrapolation for
%				  boundary points.
% 
% Out:
%	M	- the filtered matrix
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
pMethod	= ParseArgs(varargin,'zeros');
cF		= fixCell(cF);

s	= size(M);
if ~isequal(s,size(kC))
	error('M and kC must be the same size.');
end

%pad the matrix
	sFilt			= size(cF{1});
	rFilt			= floor(sFilt ./ 2);
	[M,sOld]		= padArrayExt(M,rFilt,pMethod);
	kC				= padarray(kC,rFilt);
	sPad			= s + 2*rFilt;

nF	= numel(cF);
MO	= M;
for k=1:nF
	kInc		= find(kC==k);
	nInc		= numel(kInc);
	
	if nInc
		[MCur,fCur,ndN]	= filterPrepare(MO,cF{k},kInc);
		
		M(kInc)	= sum(MCur .* fCur,ndN);
	end
end

M	= M(sOld{:});
