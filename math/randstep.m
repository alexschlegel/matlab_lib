function r = randstep(s,varargin)
% randstep
% 
% Description:	create a random array in which each element steps a random
%				amount from the previous element
% 
% Syntax:	r = randstep(s,[mStep]=1,[nDeriv]=0,[rSeed]=<generate>)
% 
% In:
% 	s			- size of the output array.  can be 1D or 2D
%	[mStep]		- maximum step size
%	[nDeriv]	- order of the derivative at which the random step occurs.  e.g. if
%				  nDeriv==0, the position steps randomly; if nDeriv==1, the velocity
%				  steps randomly, etc.
%	[rSeed]		- optionally specify the random seed arrays
% 
% Out:
% 	r	- the random step array
% 
% Updated:	2010-12-09
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[mStep,nDeriv,r]	= ParseArgs(varargin,1,0,[]);

%get the output dimensions
	nd	= numel(s);
	if nd==2 && any(s==1)
		nd	= 1;
	end
	
	if nd>2
		error('Output size must have two or fewer dimensions');
	end

%get the random array	
	switch nd
		case 1
			%get the seed
				if isempty(r)
					r	= rand(s);
				end
			
			%shift and scale it
				r	= normalize(r,'type','mean','mean',0);
				r	= r.*mStep./max(abs(r));
			
			%integrate to get the output array
				for kD=1:nDeriv+1
					r	= normalize(cumtrapz(r),'type','minmax','min',-1,'max',1);
				end
		case 2
			%we need 2^(nDeriv+1) gradient fields
				nGrad	= 2^(nDeriv+1);
				
			%get the seed
				if isempty(r)
					r	= rand([s nGrad]);
				end
				
			%shift, scale, and put in cells
				r	= squeeze(num2cell(r,[1 2]));
				for kG=1:nGrad
					r{kG}	= normalize(r{kG},'type','mean','mean',0);
					r{kG}	= r{kG}.*mStep./max(abs(r{kG}(:)));
				end
			
			%integrate
				nIntTotal	= 2.^(nDeriv+1)-1;
				progress(nIntTotal,'label','Integration');
				
				for kD=nDeriv+1:-1:1
					nGradCur	= 2^(kD-1);
					rNew		= cell(nGradCur,1);
					
					for kG=1:nGradCur
						progress;
						
						kX	= (kG-1)*2 + 1;
						kY	= (kG-1)*2 + 2;
						
						rNew{kG}	= normalize(intgrad2(r{kX},r{kY}),'type','minmax','min',-1,'max',1);
					end
					
					r	= rNew;
				end
				
			%get r out of the cell
				r	= r{1};
				
			%get rid of the artifacts
				r	= imfilter(r,fspecial('gaussian',[3 3],1),'symmetric');
				r	= medfilt2(r,[3 3],'symmetric');
	end
	