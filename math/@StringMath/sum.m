function s = sum(sm,varargin)
% sum
% 
% Description:	sum elements of a StringMath array
% 
% Syntax:	s = sum(sm,[dim]=<1st non-singleton dimension>);
% 
% In:
% 	sm		- a StringMath object
%	[dim]	- the dimension along which to sum
% 
% Out:
% 	s	- the summed array
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
dim	= ParseArgs(varargin,[]);

%we're done if sm is scalar
	if isequal(size(sm),[1 1])
		s	= sm;
		return;
	end

%get the dimension to sum along
	szIn	= size(sm);
	if isempty(dim)
		dim	= find(szIn~=1,1,'first');
	end

%make sure we have something to sum
	ndIn	= numel(szIn);
	if dim>ndIn
		s	= sm;
		return;
	end

%initialize the output
	szOut	= [szIn(1:dim-1) 1 szIn(dim+1:ndIn)];
	
	s	= p_TransferProperties(sm,StringMath);
	s	= repmat(sm,szOut);

%permute the summing dimension to the beginning
	sm	= permute(sm,[dim 1:dim-1 dim+1:ndIn]);
	
%sum each element
	nOut	= prod(szOut);
	nSum	= szIn(dim);
	for kOut=1:nOut
		kSum	= (1:nSum) + nSum*(kOut-1);
		
		for kIn=kSum
			s(kOut)	= s(kOut) + sm(kIn);
		end
	end
