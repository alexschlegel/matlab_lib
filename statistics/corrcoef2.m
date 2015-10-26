function [r,stat] = corrcoef2(x,y,varargin)
% corrcoef2
% 
% Description:	calculate the correlation coefficient between one vector and a
%				set of other vectors
% 
% Syntax:	[r,stat] = corrcoef2(x,y,<options>)
% 
% In:
% 	x	- an Nx1 array
%	y	- an s1 x ... x sM x N array
%	<options>:
%		type:		('pearson') the correlation type to calculate. either
%					'pearson' or 'spearman'.
%		twotail:	(false) true to return two-tailed p-values (i.e. significant
%					for positive or negative correlations)
% 
% Out:
% 	r		- an s1 x ... x sM array of the correlation coefficients between x
%			  and the corresponding vectors in y
%	stat	- a struct of statistics:
%				r		- r again
%				z		- the Fisher's Z transformed version of r
%				tails	- the type of test performed
%				p		- the p-values for each r
%				df		- the degrees of freedom
%				m		- the slope of the best-fit line
%				b		- y-intercept of the best-fit line
%				cutoff	- the minimum correlation that would be significant
% 
% Updated:	2015-10-23
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'type'		, 'pearson'	, ...
			'twotail'	, false		  ...
			);
	
	opt.type	= CheckInput(opt.type,'type',{'pearson','spearman'});

	n	= numel(x);
	sz	= size(y);
	nd	= numel(sz);

%resize x
	x	= repmat(reshape(x,[ones(1,nd-1) n]),[sz(1:end-1) 1]);
%get rid of NaN entries
	bNaN	= isnan(x) | isnan(y);
	x(bNaN)	= NaN;
	y(bNaN)	= NaN;
	nNoNaN	= sum(~bNaN,nd);

switch opt.type
	case 'pearson'
		%compute some schtuff
			mX		= nanmean(x,nd);
			mXR		= repmat(mX,[ones(1,nd-1) n]);
			mY		= nanmean(y,nd);
			mYR		= repmat(mY,[ones(1,nd-1) n]);
			ssX		= nansum((x-mXR).^2,nd);
			ssY		= nansum((y-mYR).^2,nd);
			
			ssXY	= nansum((x-mXR).*(y-mYR),nd);

		%correlation coefficient
			n		= ssXY;
			d		= sqrt(ssX.*ssY);
			r		= min(1,max(-1,n./d));
			r(d==0)	= NaN;
	case 'spearman'
		szCorr	= [sz(1:end-1) conditional(nd>2,[],1)];
		nPair	= prod(szCorr);
		
		x	= reshape(permute(x,[nd 1:nd-1]),n,nPair);
		y	= reshape(permute(y,[nd 1:nd-1]),n,nPair);
		
		strTail	= conditional(opt.twotail,'both','right');
		
		[r,p]	= deal(nPair,1);
		for kP=1:nPair
			[r(kP),p(kP)]	= corr(x(:,kP),y(:,kP),...
								'type'	, 'spearman'	, ...
								'tail'	, strTail		  ...
								);
		end
		
		[r,p]	= varfun(@(x) reshape(x,szCorr),r,p);
end

%stats
	if nargout>0
		%get the correlation in there
			stat.r	= r;
			stat.z	= fisherz(r);
			
		%significance
			stat.tails	= conditional(opt.twotail,'two','one');
			stat.df		= max(0,nNoNaN - 2);
			
			switch opt.type
				case 'pearson'
					stat.t		= r.*sqrt(stat.df./(1-r.^2));
					stat.p		= t2p(stat.t,stat.df,opt.twotail);
			
					tCutoff		= p2t(0.05,stat.df,opt.twotail);
					stat.cutoff	= abs(tCutoff./sqrt(tCutoff.^2 + stat.df));
					
					%best-fit parameters
						stat.m	= ssXY./ssX;
						stat.b	= mY-stat.m.*mX;
				case 'spearman'
					stat.p	= p;
					stat.t	= p2t(stat.p,stat.df,opt.twotail);
			end
	end
