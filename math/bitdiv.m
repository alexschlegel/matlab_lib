function [q,r] = bitdiv(a,b)
% bitdiv
% 
% Description:	divide two numbers represented as bit arrays
% 
% Syntax:	[q,r] = bitdiv(a,b)
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nA	= numel(a);
nB	= numel(b);

if nB<nA
	b(end+1:nA)	= false;
elseif nA<nB
	q	= false;
	r	= a;
	return;
end

q	= [];

[a,r]	= transfer(a,[],nB-1);
while numel(a)>0
	[a,r]	= transfer(a,r,1);
	
	if ~bitgt(b,r)
		q	= [true q];
		r	= bitsub(r,b);
	else
		q	= [false q];
	end
end


%------------------------------------------------------------------------------%
function [x,y] = transfer(x,y,n) 
	y	= [x(end-n+1:end) y];
	x	= x(1:end-n);
%------------------------------------------------------------------------------%
