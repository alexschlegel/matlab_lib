function [rsa,cOrder] = fMRIRSA(cPathData,C,varargin)
% fMRIRSA
% 
% Description:	perform a representational (dis)similarity analysis on fMRI data
% 
% Syntax:	[rsa,cOrder] = fMRIRSA(cPathData,C,<options>)
% 
% In:
% 	cPathData	- the path to an fMRI data set, or a cell of paths
%	C			- a cell of condition labels for each TR, or a cell of such (one
%				  for each data path)
%	<option>:
%		mask:			(<none>) a mask path/cell of mask paths to restrict the
%						voxels analyzed, or a cell of such (all cells must
%						specify the same number of masks)
%		distance:		('euclidean') the distance metric to use. see pdist.
%		order:			(<alphabetical>) an nCondition x 1 cell specifying the
%						order for conditions in the RSA matrices
%		spatiotemporal:	(false) true to treat consecutive TRs of the same
%						condition as part of the same pattern
%		blank:			('blank') the blank condition label
%		cores:			(1) the number of processor cores to use
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	rsa		- the RSA matrix, or an nData x nMask cell of RSA matrices
%	cOrder	- an nCondition x 1 cell specifying the ordering of conditions in
%			  the RSA matrices
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'mask'				, {}			, ...
		'distance'			, 'euclidean'	, ...
		'order'				, {}			, ...
		'spatiotemporal'	, false			, ...
		'blank'				, 'blank'		, ...
		'cores'				, 1				, ...
		'silent'			, false			  ...
		);

%parse the inputs
	[cPathData,bNoCell]	= ForceCell(cPathData);
	[C,cPathMask]		= ForceCell(C,opt.mask,'level',2);
	
	[cPathData,C,cPathMask]	= FillSingletonArrays(cPathData,C,cPathMask);

%process the condition arrays
	%condition order
		if isempty(opt.order)
		%get the conditions from the first dataset
			cOrder	= unique(C{1});
			
			cOrder(ismember(lower(cOrder),opt.blank))	= [];
		else
			cOrder	= opt.order;
		end
		
		nCondition	= numel(cOrder);
	%numericalize the conditions
		[b,C]	= cellfun(@(c) ismember(c,cOrder),C,'uni',false);
	
%calculate the RSA matrices
	rsa	= MultiTask(@RSAOne,{cPathData C cPathMask},...
			'description'	, 'calculating RSA matrices'	, ...
			'cores'			, opt.cores						, ...
			'silent'		, opt.silent					  ...
			);
	
	rsa	= cat(2,rsa{:})';

if bNoCell
	rsa	= rsa{1};
end

%------------------------------------------------------------------------------%
function rsa = RSAOne(strPathData,c,cPathMask)
	%load the data
		d	= NIfTI.Read(strPathData,'return','data');
		
		nTR		= size(d,4);
		nVoxel	= numel(d)/nTR;
		
		d	= double(reshape(d,nVoxel,nTR));
	%load the masks
		if ~isempty(cPathMask)
			msk	= cellfun(@(f) reshape(logical(NIfTI.Read(f,'return','data')),[],1),cPathMask,'uni',false);
		else 
			msk	= {true(nVoxel,1)};
		end
		
		nMask	= numel(msk);
	%calculate each BOLD pattern
		bold	= cell(nCondition,nMask);
		
		for kC=1:nCondition
			kTR	= find(c==kC);
			
			if opt.spatiotemporal
				df		= diff(kTR);
				kStart	= [1; find(df>1)+1];
				kEnd	= [kStart(2:end)-1; numel(kTR)];
				kTR		= arrayfun(@(s,e) kTR(s:e),kStart,kEnd,'uni',false);
			else
				kTR		= num2cell(kTR);
			end
			
			nBlock	= numel(kTR);
			nTRPer	= max(cellfun(@numel,kTR));
			
			for kM=1:nMask
				nVoxelMask	= sum(msk{kM});
				nFeature	= nVoxelMask*nTRPer;
				
				boldCur	= NaN(nFeature,nBlock);
				for kB=1:nBlock
					nTRCur	= numel(kTR{kB});
					
					for kT=1:nTRCur
						kFeature	= (1:nVoxelMask) + nVoxelMask*(kT-1);
						
						boldCur(kFeature,kB)	= d(msk{kM},kTR{kB}(kT));
					end
				end
				
				bold{kC,kM}	= mean(boldCur,2);
			end
		end
		
	%calculate each RSA pattern
		rsa	= cell(nMask,1);
		
		for kM=1:nMask
			boldCur	= cat(2,bold{:,kM})';
			
			rsa{kM}	= squareform(pdist(boldCur,opt.distance));
		end
end
%------------------------------------------------------------------------------%

end
