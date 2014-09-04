function [x,ndN,f] = filterPrepare(x,f,varargin)
% FILTERPREPARE
% 
% Description:	prepares a matrix for filtering
% 
% Syntax:	[x,ndN,f] = filterPrepare(x,f,[kInclude]=(all))
%
% In:
%	x			- a matrix
%	f			- the filter
%	[kInclude]	- the indices of elements to include in the preparation.  if
%				  this value is specified, x will be the size of k with an
%				  extra neighbor dimension
% 
% Out:
%	x	- x with a new dimension added and each element of each point's
%		  neighborhood ordered along that dimension, in column order
%		  of the filter
%	ndN	- the dimension along which the neighbors are ordered
%	f	- the filter made the same size as x so that points in the same
%		  position in each matrix correspond to filter values/neighbor value
%		  pairs.

%
% Assumptions: assumes x has already been padded, so that edge elements
%			   are filled with zeros
%
% Note: excludes neighbors with corresponding filter value==0
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bResizeF	= nargout>2;
kInclude	= ParseArgs(varargin,-1);

%find the center elements
	sX	= size(x);
	nd	= numel(sX);
	if kInclude==-1
		kInclude	= reshape(1:numel(x),sX);
	end
	sI	= size(kInclude);
	ndI	= numel(sI);
	
%find the relative positions of the neighborhood elements
	sFilt						= size(f);
	sFilt(numel(sFilt)+1:nd)	= 1;
	rFilt						= floor(sFilt ./ 2);
	%range along each dimension
		pRel	= relativeIndices(sFilt);
	%form a grid of positions for each dimension
		[pRel{:}]	= ndgrid(pRel{:});
		
	%eliminate positions that aren't included in the neighborhood
		inFilter	= find(f~=0);
		sN			= [ones(1,ndI) numel(inFilter)];
		ndN			= ndI + 1;
		for k=1:nd
			pRel{k}	= pRel{k}(inFilter);
			pRel{k}	= reshape(pRel{k},sN);
			pRel{k}	= repmat(pRel{k},[sI 1]);
		end
		if bResizeF
			f	= f(inFilter);
			f	= reshape(f,sN);
			f	= repmat(f,[sI 1]);
		end

%find the absolute positions for each inclusion element
	cKInclude		= cell(1,nd);
	[cKInclude{:}]	= ind2sub(sX,kInclude);
	kPad			= logical(zeros(sI));
	for k=1:nd
		%get the positions of the neighbor elements along
		%each dimension
			cKInclude{k}	= repmat(cKInclude{k},sN);
			cKInclude{k}	= cKInclude{k} + pRel{k};
		%we'll get some bad values from elements in the pad region.
		%just mark them 1 here and we'll get rid of them later
			kPadCur			= cKInclude{k}<1 | cKInclude{k}>sX(k);
			kPad(kPadCur)	= 1;
			cKInclude{k}(kPadCur)	= 1;
	end
	
	kInclude	= sub2ind(sX,cKInclude{:});

%we now have a size(kInclude) by #Neighbors grid of single element
%index values in x
	x	= x(kInclude);
	
%get rid of pad elements
	x(kPad)	= 0;
	if bResizeF
		f(kPad)	= 0;
	end