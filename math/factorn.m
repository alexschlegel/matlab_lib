function f = factorn(x,n)
% factorn
% 
% Description:	factor x into at most n factors, making the factors as similar
%				to each other
% 
% Syntax:	f = factorn(x,n)
% 
% In:
% 	x	- an integer
%	n	- the desire number of factors
% 
% Out:
% 	f	- the factors of x
% 
% Updated: 2014-02-12
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
fPrime	= factor(x);

%try a few factorization methods
	cF	=	{
				factorn_1(x,fPrime)
				factorn_2(x,fPrime)
			};
%take the best
	err	= cellfun(@factornError,cF);
	f	= cF{find(err==min(err),1)};

%------------------------------------------------------------------------------%
function f = factorn_1(x,fPre)
	if numel(fPre) <= n
		f	= fPre;
	else
		f	= zeros(1,n);
		
		for k=1:n
			f(k)	= prod(fPre(k:n:end));
		end
	end
end
%------------------------------------------------------------------------------%
function f = factorn_2(x,fPre)
	if numel(fPre)<=n
		f	= fPre;
		return;
	end
	
	[fPreNew,bChanged]	= CombineFactors(fPre);
	while bChanged
		fPre				= fPreNew;
		[fPreNew,bChanged]	= CombineFactors(fPre);
	end
	
	f	= factorn_1(x,fPre);
	
	function [f,b] = CombineFactors(f)
		nProdMax	= numel(f) - n + 1;
		
		if numel(f) <= n
			b	= false;
			return
		end
		
		fProd		= cumprod(f);
		d2max		= abs(fProd - f(end));
		kClosest	= min(find(d2max==min(d2max),1),nProdMax);
		fClosest	= fProd(kClosest);
		
		b	= kClosest > 1 && fClosest <= 2*f(end);
		if b
			f	= sort([fClosest f(kClosest+1:end)]);
		end
	end
end
%------------------------------------------------------------------------------%
function err = factornError(f)
	err	= max(f) - min(f);
end
%------------------------------------------------------------------------------%

end
