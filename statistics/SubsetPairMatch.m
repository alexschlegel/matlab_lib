function [aSub,bSub,kASub,kBSub,stat] = SubsetPairMatch(a,b,varargin)
% SubsetPairMatch
% 
% Description:	construct subsets of two sets such that each element of one
%				subset is paired with a close match in the other subset
% 
% Syntax:	[aSub,bSub,kASub,kBSub,stat] = SubsetMatch(a,b,<options>)
% 
% In:
% 	a	- a numerical array
%	b	- another numerical array
%	<options>:
%		p:			(0.05) a t-test between the two subsets must have p > this
%					value
%		timeout:	(60000) the maximum amount of time to search for a solution,
%					in ms
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	aSub	- the subset of a
%	bSub	- the subset of b
%	kASub	- the indices of the elements of a that were chosen
%	kBSub	- the indices of the elements of b that were chosen
%	stat	- a struct of stats about the subsets
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
tStart	= nowms;

opt	= ParseArgs(varargin,...
		'p'			, 0.05	, ...
		'timeout'	, 60000	, ...
		'silent'	, false	  ...
		);

a	= reshape(a,[],1);
b	= reshape(b,[],1);

nA	= numel(a);
nB	= numel(b);

bAMin	= nA<nB;
if bAMin
	n1	= nA;
	n2	= nB;
	x1	= a;
	x2	= b;
else
	n1	= nB;
	n2	= nA;
	x1	= b;
	x2	= a;
end

%calculate the distance between each pair
	x1Rep	= repmat(x1,[1 n2]);
	x2Rep	= repmat(x2',[n1 1]);
	d		= x1Rep - x2Rep;
	ad		= abs(d);

[pMax,nSetMax]			= deal(0);
[aSub,bSub,kASub,kBSub]	= deal([]);
[set1Max,set2Max]		= deal([]);
statMax					= struct;

sProgress	= progress('action','init','total',opt.timeout,'label','searching for a matching subset','silent',opt.silent);
strProg		= sProgress.name;

for dSubOpt=1:n1
%the maximum sub-optimality depth
	for nSubOpt=1:n1
	%the number of elements to choose suboptimal values for
		kSubOpt			= handshakes(1:n1,'group',nSubOpt);
		nSubOptGroup	= size(kSubOpt,1);
		
		for kSOGroup=1:nSubOptGroup
			kSubOptCur	= kSubOpt(kSOGroup,:);
			
			nDSubOpt		= (dSubOpt+1)^nSubOpt;
			dSubOptGroup	= zeros(nDSubOpt,nSubOpt);
			for kS=1:nSubOpt
				dSubOptGroup(:,kS)	= reshape(repmat(0:dSubOpt,[(dSubOpt+1)^(kS-1) (dSubOpt+1)^(nSubOpt-kS)]),[],1);
			end
			
			for kDSOGroup=1:nDSubOpt
				dSubOptCur	= dSubOptGroup(kDSOGroup,:);
				
				for nSet=n1:-1:1
					if pMax>opt.p && nSetMax>nSet
						break;
					end
					
					[set1Cur,set2Cur]	= deal(zeros(nSet,1));
					
					adCur	= ad;
					
					for kE=1:nSet
						kSearch	= find(~isnan(adCur));
						
						adSearch			= adCur(kSearch);
						[adSearchS,kSort]	= sort(adSearch);
						
						kESubOpt	= find(kE==kSubOptCur);
						if ~isempty(kESubOpt)
							kAdd	= 1 + dSubOptCur(kESubOpt);
						else
							kAdd	= 1;
						end
						
						[set1Cur(kE),set2Cur(kE)]	= ind2sub([n1 n2],kSearch(kSort(kAdd)));
						
						adCur(set1Cur(kE),:)	= NaN;
						adCur(:,set2Cur(kE))	= NaN;
					end
					
					[h,p,ci,stat]	= ttest(x1(set1Cur),x2(set2Cur));
					
					if p>pMax
						set1Max		= set1Cur;
						set2Max		= set2Cur;
						pMax		= p;
						nSetMax		= nSet;
						statMax		= stat;
						
						statMax.k			= [dSubOpt nSubOpt kSOGroup kDSOGroup nSet];
						statMax.kSubOptCur	= kSubOptCur;
						statMax.dSubOptCur	= dSubOptCur;
					end
					
					tNow	= nowms;
					if tNow>=tStart + opt.timeout
						ProcessOutput;
						return;
					else
						progress('current',tNow-tStart);
					end
				end
			end
		end
	end
end

ProcessOutput;

%------------------------------------------------------------------------------%
function ProcessOutput()
	if bAMin
		kASub	= set1Max;
		kBSub	= set2Max;
	else
		kASub	= set2Max;
		kBSub	= set1Max;
	end
	
	aSub	= a(kASub);
	bSub	= b(kBSub);
	
	stat	= statMax;
	stat.p	= pMax;
	
	progress('action','end','name',strProg);
end
%------------------------------------------------------------------------------%

end
