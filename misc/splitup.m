function cK = splitup(k,n)
% splitup
% 
% Description:	split an array up into evenish pieces
% 
% Syntax:	cK = splitup(k,n)
% 
% In:
% 	k	- an array of values
%	n	- the number of pieces to break k into
% 
% Out:
% 	cK	- a cell of the pieces of k
% 
% Updated: 2012-10-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%split into n pieces and distribute the extra
	nK		= numel(k);
	nPer	= floor(nK/(n));
	nExtra	= nK-n*nPer;
%split!
	kStart	= (1:nPer+1:(nExtra+1)*(nPer+1))';
	kStart	= [kStart(1:end-1); (kStart(end):nPer:nK)'];
	
	kEnd	= [kStart(2:end)-1; nK];
	
	cK	= arrayfun(@(s,e) k(s:e),kStart,kEnd,'UniformOutput',false);
