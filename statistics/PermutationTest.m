function stat = PermutationTest(f,x,varargin)
% PermutationTest
% 
% Description:	perform a one-tailed permutation test to determine the
%				significance of a result
% 
% Syntax:	stat = PermutationTest(f,x,[v]=<calculate>,<options>)
% 
% In:
% 	f	- a function that takes the data and returns the scalar measure to test.
%		  each element of x is passed as a separate argument if x is a cell
%		  array.
%	x	- an array of data, or a cell of arrays of data all of which have the
%		  same size.
%	[v]	- the unpermuted value of f(x{:})
%	<options>:
%		dim:			(1) the dimension along which to permute x. can also be
%						one of the following:
%							'label':	if x is an NxN matrix, permute the
%										labels of a confusion matrix
%							'all':		permute all values of x
%		permutations:	(100) the number of permuted results to calculate
%		alpha:			(0.05) the significance level
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	stat	- a struct of results:
%				v:		the unpermuted value of f(x{:})
%				nperm:	the number of permutations performed
%				m:		the mean permuted value
%				sd:		the standard deviation of the permuted values
%				thresh:	the threshold for significance
%				p:		the percentage of permuted values that were >= the
%						actual value (i.e. the p-value of the permutation test)
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[v,opt]	= ParseArgs(varargin,[],...
			'dim'			, 1		, ...
			'permutations'	, 100	, ...
			'alpha'			, 0.05	, ...
			'silent'		, false	  ...
			);

x	= ForceCell(x);
s	= size(x{1});
nd	= numel(s);

%get the permutation type
	switch class(opt.dim)
		case 'char'
			opt.dim		= CheckInput(opt.dim,'dim',{'label','all'});
			
			switch opt.dim
				case 'label'
					nDim		= s(1);
					fPermute	= @ReorderConfusion;
				case 'all'
					nDim		= prod(s);
					fPermute	= @(x,k) reshape(x(k),size(x));
			end
		otherwise
			nDim		= s(opt.dim);
			fPermute	= @(x,k) PermuteDim(x,opt.dim,k);
	end

%calculate the unpermuted value
	if isempty(v)
		v	= f(x{:});
	end

%construct the array reorderings
	perm	= genperm(nDim,opt.permutations);
	nPerm	= size(perm,1);

%calculate each permuted value
	vPermute	= NaN(nPerm,1);
	
	progress('action','init','total',nPerm,'label','computing significance','silent',opt.silent);
	for kP=1:nPerm
		%permute the data
			xPerm	= cellfun(@(x) fPermute(x,perm(kP,:)),x,'uni',false);
		
		%calculate the permuted value
			vPermute(kP)	= f(xPerm{:});
		
		progress;
	end

%statistics
	stat.v		= v;
	stat.nperm	= nPerm;
	stat.m		= mean(vPermute);
	stat.sd		= std(vPermute);
	stat.thresh	= prctile(vPermute,100*(1-opt.alpha));
	stat.p		= sum(vPermute>=v)./nPerm;

%------------------------------------------------------------------------------%
function x = PermuteDim(x,kDim,k)
	nd			= numel(size(x));
	cInd		= repmat({':'},[nd 1]);
	cInd{kDim}	= k;
	
	x	= x(cInd{:});
end
%------------------------------------------------------------------------------%

end
