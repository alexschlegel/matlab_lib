function a = ArrayPierce(x,p,v)
% ArrayPierce
% 
% Description:	extract a "core" from an array from a given position in a given
%				direction
% 
% Syntax:	a = ArrayPierce(x,p,v)
% 
% In:
% 	x	- 
% 
% Out:
% 		- 
% 
% Side-effects:	
% 
% Assumptions:	
% 
% Notes:	
% 
% Example:	
% 
% Updated: 2012-03-29
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= size(x)';
nd	= numel(s);
p	= reshape(p,nd,1);
v	= reshape(v,nd,1);

%distance between starting point and the edge
	d	= s - p;
%number of steps between starting point and edge
	v			= v./max(abs(v));
	ns			= inf(nd,1);
	bLeft		= v<0;
	ns(bLeft)	= -p(bLeft)./v(bLeft);
	ns(~bLeft)	= d(~bLeft)./v(~bLeft);
%minimum number of steps
	nsMin	= ceil(min(ns));
%calculate the points along those steps
	step	= (0:nsMin)';
	
	switch nd
		case 2
			pA1		= round(p(1) + v(1).*step);
			bGood	= pA1>0 & pA1<=s(1);
			
			pA1		= pA1(bGood);
			step	= step(bGood);
			
			p2		= p(2)-1;
			pA2		= round(p2 + v(2).*step);
			bGood	= pA2>=0 & pA2<s(2);
			
			pA1	= pA1(bGood);
			pA2	= pA2(bGood);
			
			nP	= numel(pA1);
		case 3
			pA1		= round(p(1) + v(1).*step);
			bGood	= pA1>0 & pA1<=s(1);
			
			pA1		= pA1(bGood);
			step	= step(bGood);
			
			p2		= p(2)-1;
			pA2		= round(p2 + v(2).*step);
			bGood	= pA2>=0 & pA2<s(2);
			
			pA1		= pA1(bGood);
			pA2		= pA2(bGood);
			step	= step(bGood);
			
			p3		= p(3)-1;
			pA3		= round(p3 + v(3).*step);
			bGood	= pA3>=0 & pA3<s(3);
			
			pA1	= pA1(bGood);
			pA2	= pA2(bGood);
			pA3	= pA3(bGood);
			
			nP	= numel(pA1);
		otherwise
			pA		= zeros(nsMin+1,nd);
			bGood	= true(nsMin+1,1);
			
			for kd=1:nd
				pA(bGood,kd)	= round(p(kd) + v(kd).*step(bGood));
				
				bGood(bGood)	= pA(bGood,kd)>0 & pA(bGood,kd)<=s(kd);
			end
			
			pA	= pA(bGood,:);
			nP	= size(pA,1);
	end
	
	if nP==0
		a	= [];
		
		return;
	end
%get the values of these points
	switch nd
		case 2
			kA	= pA1 + s(1).*pA2;
		case 3
			kA	= pA1 + s(1).*(pA2 + s(2).*pA3);
		otherwise
			kA	= mat2cell(pA,nP,ones(nd,1));
			kA	= sub2ind(s',kA{:});
	end

a	= x(kA);
