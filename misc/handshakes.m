function [g,k] = handshakes(x,varargin)
% handshakes
% 
% Description:	return every possible pairing (or other grouping) of elements in
%				x
% 
% Syntax:	[g,k] = handshakes(x,[N]=2)
% 
% In:
% 	x	- an array
%	N	- the number of elements in one grouping
% 
% Out:
%	g	- an nGroup x N array of groupings
%	k	- the indices in x of the elements in h
% 
% Updated: 2011-03-23
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
N	= ParseArgs(varargin,2);

n	= numel(x);

if n<N
	error('Fewer elements than group size.');
end

if N==1
	g	= reshape(x,[],1);
	k	= reshape(1:n,[],1);
	return;
end

if N==2
	nHandshake	= sum(1:n-1);
else
	nHandshake	= choose(n,N);
end
g				= repmat(x(1),[nHandshake N]);
k				= zeros(nHandshake,N);

kH	= 1;
for k1=1:n-N+1
	[gCur,kCur]	= handshakes(x(k1+1:end),N-1);
	nHCur		= size(gCur,1);
	kHCur		= kH:kH+nHCur-1;
	
	g(kHCur,:)	= [repmat(x(k1),[nHCur 1]) gCur];
	k(kHCur,:)	= [repmat(k1,[nHCur 1]) kCur+k1];
	
	kH	= kH + nHCur;
end
