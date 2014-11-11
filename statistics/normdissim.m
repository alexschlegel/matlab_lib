function D = normdissim(x,varargin)
% normdissim
% 
% Description:	calculate the normed dissimilarity matrix between two matrices
% 
% Syntax:	D = normdissim(x,[y]=x,<options>)
% 
% In:
% 	x	- an M x N matrix
%	y	- an M x P matrix
%	<options>:
%		method:	('dist') either 'dist' or 'corr' to specify whether distance or
%				(1-correlation) should be used
% 
% Out:
% 	D	- the N x P normed dissimilarity matrix
% 
% Updated: 2012-09-24
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[y,opt]	= ParseArgs(varargin,x,...
			'method'	, 'dist'	  ...
			);
opt.method	= CheckInput(opt.method,'method',{'dist','corr'});

switch opt.method
	case 'dist'
		mX	= sqrt(sum(x.^2));
		mY	= sqrt(sum(y.^2));
		
		D	= 1-(x'*y)./(mX'*mY);
	case 'corr'
		[M,N]	= size(x);
		[M,P]	= size(y);
		
		D	= zeros(N,P);
		
		for kP=1:P
			D(:,kP)	= corrcoef2(y(:,kP),x');
		end
		
		D	= 1-D;
end
