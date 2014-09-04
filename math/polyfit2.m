function varargout = polyfit2(x,y,n)
% polyfit2
% 
% Description:	a variation of polyfit that doesn't break with NaNs and accepts
%				different types of input
% 
% Syntax:	p = polyfit2(x,y,n) OR
%			[p1,...,pN] = polyfit2(x,y,n)
% 
% In:
% 	x	- a 1D vector or nSignal x nSample array of x values
% 	y	- a 1D vector or nSignal x nSample array of y values
%	n	- the order of polynomial to fit
% 
% Out:
% 	p	- an Nx1 array of best-fit polynomial coefficients
%	pK	- the Kth best-fit polynomial coefficient
% 
% Updated: 2010-07-28
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
%reshape the data
	bColumnX	= size(x,2)==1;
	if bColumnX
		x	= reshape(x,1,[]);
	end
	bColumnY	= size(y,2)==1;
	if bColumnY
		y	= reshape(y,1,[]);
	end

%fill unfull arrays
	[x,y] = FillSingletonArrays(x,y);
%number of signals and samples
	[nSignal,nSample]	= size(x);
%put each signal in a cell
	cX	= mat2cell(x,ones(nSignal,1),nSample);
	cY	= mat2cell(y,ones(nSignal,1),nSample);
%get the best fit polynomrial for each signal
	cP	= cellfun(@(x,y) polyfit(x,y,n),cX,cY,'UniformOutput',false);
%transform back to p
	p	= cell2mat(cP);
%deal to the output
	if nargout==n+1
		varargout	= mat2cell(p,nSignal,ones(1,n+1));
	else
		varargout	= {p};
	end
