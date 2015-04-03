function res = MVPAHigherStats(res)
% MVPAHigherStats
% 
% Description:	perform higher-level stats on MVPA results (specifically FDR
%				correct p-values from the same analyses)
% 
% Syntax:	res = MVPAHigherStats(res)
% 
% Updated: 2015-03-31
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

cSubPath	=	{
					{'allway'; 'stats'; 'accuracy'}
					{'allway'; 'stats'; 'confusion'}
					{'twoway'; 'stats'; 'accuracy'}
					{'twoway'; 'stats'; 'confusion'}
				};
nSubPath	= numel(cSubPath);

for kS=1:nSubPath
	res.result	= structtreefdr(res.result,'include',cSubPath{kS});
end
