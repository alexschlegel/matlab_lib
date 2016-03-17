function [res,varargout] = knapsack(szKnapsack,szBox,varargin)
% knapsack
% 
% Description:	solve an ND knapsack problem, in which boxes with specified
%				sizes and values must be fit optimally into an N-dimensional
%				knapsack
% 
% Syntax: [res,imKnapsack] = knapsack(szKnapsack,szBox,[valBox]=<ones>,<options>)
% 
% In:
%	szKnapsack	- an ND-length array specifying the size of the knapsack
%	szBox		- an nBox x ND array specifying the (integer) dimensions of each
%				  box
%	[valBox]	- an ND-length array specifying the value of each box
%	<options>:
%		guillotine:	(true) true to only allow guillotine cuts through the
%					knapsack
%		repeat:		(true) true if multiples of a box may be placed in the
%					knapsack
%		rotate:		(<true if 2D>) true if the boxes may be rotated 90 degrees.
%					only implemented for 2D knapsacks.
% 
% Out:
%	res			- a struct of results:
%					kBox:		an N x 1 array of the index of each box placed
%								in the knapsack
%					posBox		an N x (2*ND) array specifying the position of
%								each box in the knapsack. e.g. for 2D knapsacks
%								this would be N x 4, and the kth row would
%								specify the (r1,c1,r2,c2) position of the kth
%								box placed in the knapsack.
%					valBox		an N x 1 array specifying the value of each box
%								in the knapsack
%					valTotal:	the total value of the boxes placed in the
%								knapsack
%	imKnapsack	- for 1 or 2-D knapsacks, an image of the box placement
% 
% Updated:	2016-03-02
% Copyright 2016 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	[valBox,opt]	= ParseArgs(varargin,[],...
						'guillotine'	, true	, ...
						'repeat'		, true	, ...
						'rotate'		, []	  ...
						);
	
	nd		= numel(szKnapsack);
	
	[nBox,ndBox]	= size(szBox);
	assert(ndBox==nd,'szBox must be nBox x ND');
	
	if isempty(valBox)
		valBox	= ones(nBox,1);
	end
	assert(numel(valBox)==nBox,'valBox must have length nBox');
	
	assert(opt.guillotine,'allowing non-guillotine cuts is not implemented');
	assert(opt.repeat,'disallowed repeats are not implemented');
	
	if isempty(opt.rotate)
		opt.rotate	= nd==2;
	end
	assert(~opt.rotate || nd==2,'rotation is only implemented for 2D knapsacks');

%add rotated boxes
	if opt.rotate
		szBox	= [szBox; szBox(:,end:-1:1)];
		valBox	= repmat(valBox,[2 1]);
	end

%sort the boxes by decreasing value
	[valBox,kSort]	= sort(valBox,'descend');
	szBox	= szBox(kSort,:);

%initialize the results
	szAll	= szKnapsack+1;
	if nd==1
		val		= zeros(szAll,1);
		box		= cell(szAll,1);
	else
		val		= zeros(szAll);
		box		= cell(szAll);
	end

%determine the optimal arrangement for all knapsack sizes with a single box
	bFilled	= false(szAll);
	bCheck	= false(szAll);
	for kB=1:nBox
		kBigEnough					= arrayfun(@(szB,szK) szB+1:szK,szBox(kB,:),szAll,'uni',false);
		bCheckNow					= bCheck;
		bCheckNow(kBigEnough{:})	= true;
		
		bFillNow	= ~bFilled & bCheckNow;
		
		bFilled(bFillNow)	= true;
		val(bFillNow)		= valBox(kB);
		box(bFillNow)		= {[zeros(1,nd) szBox(kB,:) valBox(kB) kB]};
	end

%evaluate each slice through each knapsack for a more optimal solution
	%get the sizes of each subknapsack
		kSize			= arrayfun(@(sz) 1:sz+1,szKnapsack,'uni',false);
		[cKSize{1:nd}]	= ndgrid(kSize{end:-1:1});
		cKSize			= cellfun(@(k) reshape(k,[],1),cKSize,'uni',false);
		kSize			= cat(2,cKSize{end:-1:1});
		nKnapsack		= size(kSize,1);
	%loop through each subknapsack
		for kS=1:nKnapsack
			kSizeNow	= num2cell(kSize(kS,:));
			%evaluate each slice dimension
				for kD=1:nd
					%evaluate each slice
						for kL=1:floor(kSize(kS,kD)/2)+1
							kCheck1		= kSizeNow;
							kCheck1{kD}	= kL;
							
							kCheck2		= kSizeNow;
							kCheck2{kD}	= kSizeNow{kD} - kL + 1;
							
							valCheck	= val(kCheck1{:}) + val(kCheck2{:});
							if valCheck > val(kSizeNow{:})
								val(kSizeNow{:})	= valCheck;
								
								box1				= box{kCheck1{:}};
								box2				= box{kCheck2{:}};
								box2(:,kD+[0 nd])	= box2(:,kD+[0 nd]) + kL - 1;
								box{kSizeNow{:}}	= [box1; box2];
							end
						end
				end
		end

%construct the output
	solution	= box{end};
	posBox		= solution(:,1:2*nd);
	valBox		= solution(:,2*nd+1);
	kBox		= solution(:,end);
	valTotal	= sum(valBox);
	
	res = struct(...
			'kBox'		, kBox		, ...
			'posBox'	, posBox	, ...
			'valBox'	, valBox	, ...
			'valTotal'	, valTotal	  ...
			);
	
	if nargout==2
		if nd<=2
			varargout{1}	= ConstructImage(res);
		else
			varargout{1}	= [];
		end
	end

%-------------------------------------------------------------------------------
function im = ConstructImage(res)
	nBox	= numel(res.kBox);
	
	if nd==1
		szKnapsack	= [szKnapsack 1];
		res.posBox	= [res.posBox(:,1) zeros(nBox,1) res.posBox(:,2) ones(nBox,1)];
	end
	
	colMin		= 0.25;
	colMax		= 1;
	colBorder	= 0;
	
	colBox	= normalize(res.valBox,'min',colMin,'max',colMax);
	
	szMax		= 600;
	szFactor	= szMax / max(szKnapsack);
	szImage		= round(szKnapsack * szFactor);
	
	im	= zeros(szImage);
	
	for kB=1:nBox
		rc1		= res.posBox(kB,1:2);
		rc2		= res.posBox(kB,3:4);
		szBox	= rc2 - rc1;
		
		szImBox	= round(szBox * szFactor);
		pBox	= round(rc1 * szFactor) + 1;
		
		imBox	= colBox(kB)*ones(szImBox);
		imBox	= imborder(imBox,...
					'c'	, colBorder	  ...
					);
		
		im	= InsertImage(im,imBox,pBox);
	end
end
%-------------------------------------------------------------------------------

end
