function y = perms2(x)
% perms2
% 
% Description:	same as perms, but with a less crazy ordering of the
%				permutations
% 
% Syntax:	y = perms2(x)
% 
% Updated: 2015-03-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
n	= numel(x);

if n<=1
	y	= x;
else
	kSub	= perms2(2:n);
	nSub	= size(kSub,1);
	kSub	= [ones(nSub,1) kSub];
	
	y	= zeros(nSub*n,n);
	
	for k=1:n
		xCur	= x([k 1:k-1 k+1:end]);
		
		kStart	= nSub*(k-1) + 1;
		kEnd	= kStart + nSub - 1;
		
		y(kStart:kEnd,:)	= xCur(kSub);
	end
end
