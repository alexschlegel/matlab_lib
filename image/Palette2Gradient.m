function [colG1,colG2,p] = Palette2Gradient(pal)
% Palette2Gradient
% 
% Description:	convert a palette to a series of gradients between colors
% 
% Syntax:	[colG1,colG2,p] = Palette2Gradient(pal)
% 
% In:
% 	pal	- an Nx3 palette array
% 
% Out:
% 	colG1	- an Mx3 array of the starting color of each gradient
%	colG2	- an Mx3 array of the ending color of each gradient
%	p		- an M-length cell of parametric step functions between the array
%			  colors
% 
% Updated:	2008-12-19
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%number of colors
	n	= size(pal,1);
	
%initialize stuff
	[colG1,colG2]	= deal(zeros(0,3));
	p				= {};

	
%step through the colors
	k	= 1;
	while k<n
		%get the first color of the gradient
			colG1	= [colG1; pal(k,:)];
		%step along the palette until every color between colG1 and the test
		%color can be expressed as a fractional sum of the two
			bFound	= false;
			kTest	= n+1;
			while ~bFound
				kTest	= kTest-1;
				t		= GetStep(pal(k:kTest,:));
				bFound	= ~isempty(t);
			end
		%fill in the last gradient color and the step function
			colG2		= [colG2; pal(kTest,:)];
			p{end+1}	= t;
		%update k
			k	= kTest+1;
	end
	if k==n
		colG1		= [colG1; pal(n,:)];
		colG2		= [colG2; NaN NaN NaN];
		p{end+1}	= 0;
	end
%------------------------------------------------------------------------------%
function t = GetStep(x)
%test to see if all elements in x can be expressed as a fractional sum of the
%first and last elements.  return the parametric step function if it exists
	w	= warning('off','MATLAB:divideByZero');
	
	[n,nC]	= size(x);
	
	c1	= x(1,:);
	c2	= x(end,:);
	
	%see if each x can be expressed as x=(1-f)*c1 + f*c2
	%=> f*(c2-c1)=x-c1
	%=> f=(x-c1)./(c2-c1), all f's in each row should be the same and in [0,1]
		c1	= repmat(c1,[n 1]);
		c2	= repmat(c2,[n 1]);
		f	= (x-c1)./(c2-c1);
		
		%for positions where x==c2==c1, set f equal to one of the non-NaN values
			fMax		= repmat(max(f,[],2),[1 nC]);
			bNaN		= isnan(f);
			f(bNaN)		= fMax(bNaN);
		
		if all(f(:,1)<=1) && all(f(:,1)>=0) && all(abs(f(:,1)-f(:,2))<=eps) && all(abs(f(:,1)-f(:,3))<=eps)
			t	= reshape(f(:,1),[],1);
		else
			t	= [];
		end
		
	warning(w);
%------------------------------------------------------------------------------%
