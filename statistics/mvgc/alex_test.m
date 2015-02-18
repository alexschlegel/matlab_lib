%compare my GrangerCausality to Seth's code
n	= 100;
nd	= 5;

X	= randn(n,nd);
Y	= [randn(1,nd); X(1:end-1,:)] + randn(n,nd);
%Y	= randn(n,nd);

%seth
	strDirMVGC	= '/home/alex/code/MATLAB/lib/statistics/mvgc';
	cPathMVGC	= genpath(strDirMVGC);
	
	addpath(genpath(strDirMVGC));
	
	YX	= [Y X]';
	
	morder		= 1;
	regmode		= 'OLS';
	acmaxlags	= 1000;
	
	[A,SIG,E]	= tsdata_to_var(YX,morder,regmode);
	
	assert(~isbad(A),'VAR estimation failed');
	
	[G,info]	= var_to_autocov(A,SIG,acmaxlags);
	
	var_info(info,true);
	
	gc.seth	= autocov_to_mvgc(G,1:nd,nd+1:2*nd);
	
	rmpath(genpath(strDirMVGC));

%me
	gc.me	= GrangerCausality(X,Y);

