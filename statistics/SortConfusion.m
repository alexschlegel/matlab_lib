function [cm,kSort,kUnsort] = SortConfusion(cm,varargin)
% SortConfusion
% 
% Description:	sort a confusion matrix so similar/dissimilar items are next to
%				each other
% 
% Syntax:	[cm,kSort,kUnsort] = SortConfusion(cm,[strMode]='highest')
% 
% In:
% 	cm			- a confusion/similarity matrix
%	[strMode]	- the sorting method, either 'highest' to place higher-valued
%				  pairs together, 'lowest' for lowest-valued pairs
% 
% Out:
% 	cm		- the sorted confusion matrix
%	kSort	- the sorting index to pass to ReorderConfusion to get the sorted
%			  matrix
%	kUnsort	- the sorting index to pass to ReorderConfusion to revert the sorted
%			  matrix to its unsorted form
% 
% Updated: 2012-03-08
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strMode	= ParseArgs(varargin,'highest');
strMode	= CheckInput(strMode,'sorting mode',{'highest','lowest'});

fCompare		= switch2(strMode,...
					'highest'	, @max	, ...
					'lowest'	, @min	  ...
					);
fRelationship	= @mean;

n	= size(cm,1);

%cluster all the objects
	cmC						= cm;
	cmC(logical(eye(n)))	= NaN;
	
	cluster		= num2cell(1:n);
	nCluster	= n;
	
	while nCluster>1
		%combine the closest clusters
			[k1,k2]	= find(cmC==fCompare(cmC(:)),1);
			
			n1	= numel(cluster{k1});
			n2	= numel(cluster{k2});
			
			if n1>n2
				kBigger		= k1;
				kSmaller	= k2;
			else
				kBigger		= k2;
				kSmaller	= k1;
			end
			
			cluster	= [{[cluster{kBigger}; cluster{kSmaller}]} cluster(setdiff(1:nCluster,[k1 k2]))];
			
			nCluster	= nCluster - 1;
		%recalculate the relationships
			cmC	= zeros(nCluster);
			
			for k1=1:nCluster
				for k2=1:nCluster
					x			= reshape(cm(cluster{k1},cluster{k2}),[],1);
					cmC(k1,k2)	= fRelationship(x);
				end
			end
			
			cmC(logical(eye(nCluster)))	= NaN;
	end
%construct the sorting array
	kSort			= cat(1,cluster{:});
	kSort			= [kSort; reshape(setdiff(1:n,kSort),[],1)];
	[dummy,kUnsort]	= sort(kSort);
%reorder the confusion matrix
	cm	= ReorderConfusion(cm,kSort);
