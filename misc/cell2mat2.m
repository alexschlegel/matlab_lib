function x = cell2mat2(c)
% cell2mat2
% 
% Description:	a version of cell2mat that can better undo mat2cell calls
% 
% Syntax:	x = cell2mat2(c)
% 
% Updated: 2015-03-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the output dimensions
	szC		= size(c);
	ndC		= numel(szC);
	szInner	= reshape(cellfun(@size,c,'uni',false),[],1);
	ndInner	= max(cellfun(@numel,szInner));
	ndOut	= max(ndC,ndInner);
%get the output size
	szDim	= arrayfun(@(d) GetDimSizes(c,d,ndOut),(1:ndOut),'uni',false);
	szOut	= cellfun(@sum,szDim);
	nOut	= prod(szOut);

%construct the output
	cmDim	= cellfun(@cumsum,szDim,'uni',false);
	
	x	= cell(szOut);
	
	[cSub,cCSub,cXSub]	= deal(cell(ndOut,1));
	for k=1:nOut
		[cSub{1:ndOut}]	= ind2sub(szOut,k);
		
		for kD=1:ndOut
			cCSub{kD}	= find(cSub{kD}<=cmDim{kD},1);
			
			if cCSub{kD}==1
				kStart	= 0;
			else
				kStart	= cmDim{kD}(cCSub{kD}-1);
			end
			
			cXSub{kD}	= cSub{kD} - kStart;
		end
		
		cCur	= c{cCSub{:}};
		x{k}	= cCur{cXSub{:}};
	end


%------------------------------------------------------------------------------%
function sz = GetDimSizes(c,d,nd) 
	subs	= num2cell(ones(1,nd));
	subs{d}	= ':';
	sz		= reshape(cellfun(@(x) size(x,d),c(subs{:})),[],1);
%------------------------------------------------------------------------------%
