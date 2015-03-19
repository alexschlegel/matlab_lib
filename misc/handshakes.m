function [xGroup,kGroup] = handshakes(x,varargin)
% handshakes
% 
% Description:	return every possible pairing (or other grouping) of elements in
%				x
% 
% Syntax:	[xGroup,kGroup] = handshakes(x,<options>)
% 
% In:
% 	x	- an array
%	<options>:
%		group:		(2) the number of element in one group
%		ordered:	(false) true if the order of members in a group matters
% 
% Out:
%	xGroup	- an nGroup x <group> array of groupings
%	kGroup	- the indices in x of the elements in xGroup
% 
% Updated: 2015-03-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'group'		, 2		, ...
		'ordered'	, false	  ...
		);

n	= numel(x);

assert(n>=opt.group,'fewer elements than group size');

if opt.group==1
	xGroup	= reshape(x,[],1);
	kGroup	= reshape(1:n,[],1);
	return;
end

%get the group indices
	if opt.ordered
		kSub	= handshakes(2:n,'group',opt.group-1,'ordered',true);
		nSub	= size(kSub,1);
		kSub	= [ones(nSub,1) kSub];
		
		kGroup	= zeros(nSub*n,opt.group);
		
		kX	= 1:n;
		for k=1:n
			kCur	= kX([k 1:k-1 k+1:end]);
			
			kStart	= nSub*(k-1) + 1;
			kEnd	= kStart + nSub - 1;
			
			kGroup(kStart:kEnd,:)	= kCur(kSub);
		end
	else
		n	= numel(x);
		
		nGroup	= choose(n,opt.group);
		
		kGroup	= zeros(nGroup,opt.group);
		kStart	= 1;
		for k=1:n-opt.group+1
			kSub	= handshakes(k+1:n,'group',opt.group-1,'ordered',false);
			nSub	= size(kSub,1);
			
			kEnd	= kStart + nSub - 1;
			kCur	= kStart:kEnd;
			
			kGroup(kCur,1)		= k;
			kGroup(kCur,2:end)	= kSub;
			
			kStart	= kEnd+1;
		end
	end

xGroup	= x(kGroup);
