function [kRM,kCM,x,kRN,kCN,bTimedOut] = MatrixMatch(m,varargin)
% MatrixMatch
% 
% Description:	use to match one set of things with another based on preferences
% 
% Syntax:	[kRM,kCM,x,kRN,kCN] = MatrixMatch(m,<options>)
% 
% In:
% 	m	- an R x C matrix representing matching preferences between a set of R
%		  items and another set of C items.  for instance, m(i,j) would be the
%		  preference associated with matching item Ri with item Cj.  positive
%		  values indicate acceptable matches, with magnitude indicating degree
%		  of preference.  any other values represent unacceptable matches.
%	<options>:
%		timeout:	(60000) the maximum time, in milliseconds, after which the
%					function will return its best result if no exact solution
%					has been found
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	kRM	- an M x 1 array of the rows that were successfully matched
%	kCM	- an M x 1 array of the columns to which the rows in kRM were matched
%	x	- an M x 1 array of the preference value associated with each match
%	kRN	- an N x 1 array of the rows that went unmatched
%	kCN	- an N x 1 array of the columns that went unmatched
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[R,C]	= size(m);
	
kR	= (1:R)';
kC	= (1:C)';
	
%parse the input
	bFirst	= nargin<2 || ~isstruct(varargin{1});
	if bFirst
	%first call 
		opt	= ParseArgs(varargin,...
				'start'		, nowms	, ...
				'depth'		, R*C	, ...
				'timeout'	, 60000	, ...
				'cores'		, 1		, ...
				'silent'	, false	  ...
				);
		
		%condition m
			m(isnan(m) | m<0)	= 0;
		
		bMulti		= opt.cores>1;
		nMultiMax	= 100;
	else
	%recursive call
		opt	= varargin{1};
		
		bMulti	= false;
	end
%initialize the outputs
	[kRM,kCM,x,kRN,kCN]	= deal([]);
%have we timed out?
	bTimedOut	= nowms >= opt.start + opt.timeout;
	if bTimedOut
		kRN	= kR;
		kCN	= kC;
		
		return;
	end
%get rid of non-matching rows and columns
	b	= m>0;
	nR	= sum(b,2);
	nC	= sum(b,1)';
	
	bR		= nR>0;
	bC		= nC>0;
	m		= m(bR,bC);
	[R,C]	= size(m);
	kRNBase	= kR(~bR);
	kCNBase	= kC(~bC);
	kR		= kR(bR);
	kC		= kC(bC);
%does anything match?
	if isempty(m)
		return;
	end
%match
	%find the matches
		b	= m>0;
		nR	= sum(b,2);
		nC	= sum(b,1)';
	%find the least matching rows and columns
		n			= [nR; nC];
		rc			= [true(R,1); false(C,1)];
		k			= [(1:R)'; (1:C)'];
		[s,kSort]	= sort(n);
		rc			= rc(kSort);
		k			= k(kSort);
		nRC			= numel(k);
	
	if bFirst
		sProgress	= progress('action','init','total',opt.timeout,'label','searching for matrixmatch solution','silent',opt.silent);
		opt.name	= sProgress.name;
		
		if bMulti
		%prepare the multicore search
			[bMulti,opt.cores]	= MATLABPoolOpen(opt.cores,'silent',opt.silent);
			
			[coptSub,cx1,ckRSub2,ckCSub2,cmSub2,ckRM1,ckCM1]	= deal(cell(nMultiMax,1));
			[ckRM,ckCM,cx,ckRN,ckCN]							= deal(cell(nMultiMax,1));
			kMulti												= 1;
		end
	end
	
	for d=1:opt.depth
	%estimate the matches with increasing complexity
		if bFirst
			status(['starting depth: ' num2str(d)],'silent',opt.silent);
		end
		
		bDidSomething	= false;
		
		optSub			= opt;
		optSub.depth	= d;
		
		kD		= 1;
		for kRC=1:nRC
		%step through possible matches up to the specified depth
			%get the row or column to match
				rcCur	= k(kRC);
				
				if rc(kRC)
				%it's a row
					mCur	= m(k(kRC),:)';
				else
				%it's a column
					mCur	= m(:,k(kRC));
				end
				
				%sort descending so we get the most favorable matches first
					kCur				= find(mCur);
					[mCurSort,kCurSort]	= sort(mCur(kCur),'descend');
					kCur				= kCur(kCurSort);
					nCur				= numel(kCur);
			
			for kInRC=1:nCur
			%step through the possible matches within that row or column
				%make the match
					if rc(kRC)
						kRM1	= k(kRC);
						kCM1	= kCur(kInRC);
					else
						kRM1	= kCur(kInRC);
						kCM1	= k(kRC); 
					end
					x1	= m(kRM1,kCM1);
					
					kRSub2								= [1:kRM1-1 kRM1+1:R];
					kCSub2								= [1:kCM1-1 kCM1+1:C];
					mSub2								= m(kRSub2,kCSub2);
					
					if ~bMulti
					%do the search
						[kRM2,kCM2,x2,kRN2,kCN2,bTimedOut]	= MatrixMatch(mSub2,optSub);
						
						if bTimedOut
							break;
						end
						
						%how did we do?
							nMatchPre	= numel(kRM);
							nMatchCur	= 1 + numel(kRM2);
							xPre		= sum(x);
							xCur		= x1 + sum(x2);
							
							if nMatchCur > nMatchPre || (nMatchCur==nMatchPre && xCur>xPre)
								kRM	= [kR(kRM1); kR(kRSub2(kRM2))];
								kCM	= [kC(kCM1); kC(kCSub2(kCM2))];
								x	= [x1; x2];
								kRN	= [kRNBase; kR(kRSub2(kRN2))];
								kCN	= [kCNBase; kC(kCSub2(kCN2))];
							end
					else
					%just prepare the search
						coptSub{kMulti}	= optSub;
						cx1{kMulti}		= x1;
						ckRSub2{kMulti}	= kRSub2;
						ckCSub2{kMulti}	= kCSub2;
						cmSub2{kMulti}	= mSub2;
						ckRM1{kMulti}	= kRM1;
						ckCM1{kMulti}	= kCM1;
						
						kMulti	= kMulti+1;
					end
					
					bDidSomething	= true;
					
					if opt.cores==1 || bFirst
						t	= nowms-opt.start;
						progress('current',min(opt.timeout-1,round(t)),'name',opt.name);
					end
				
				kD		= kD+1;
				
				if kD>d
					break;
				end
			end
			
			if kD>d || bTimedOut
				break;
			end
		end
		
		if bMulti
		%do the search!
			parfor kM=1:kMulti
				if nowms<=opt.start + opt.timeout
				%still good
					[kRM2,kCM2,x2,kRN2,kCN2,bTimedOut]	= MatrixMatch(cmSub2{kM},coptSub{kM});
					
					if ~bTimedOut
						ckRM{kM}	= [kR(ckRM1{kM}); kR(ckRSub2{kM}(kRM2))];
						ckCM{kM}	= [kC(ckCM1{kM}); kC(ckCSub2{kM}(kCM2))];
						cx{kM}		= [cx1{kM}; x2];
						ckRN{kM}	= [kRNBase; kR(ckRSub2{kM}(kRN2))];
						ckCN{kM}	= [kCNBase; kC(ckCSub2{kM}(kCN2))];
					end
				else
					kRM2	= [];
				end
			end
		%get the best result
			%result with most matches
				nMatch	= cellfun(@numel,ckRM);
				kBest	= find(nMatch==max(nMatch));
			%if we have a tie, take the highest preference match
				if numel(kBest)>1
					xMatch	= cellfun(@sum,cx);
					kBest	= kBest(find(xMatch==max(xMatch),1));
				end
		%how did we do?
			nMatchPre	= numel(kRM);
			nMatchCur	= numel(ckRM{kBest});
			xPre		= sum(x);
			xCur		= sum(cx{kBest});
			
			if nMatchCur > nMatchPre || (nMatchCur==nMatchPre && xCur>xPre)
				kRM	= ckRM{kBest};
				kCM	= ckCM{kBest};
				x	= cx{kBest};
				kRN	= ckRN{kBest};
				kCN	= ckCN{kBest};
			end
		%reset our holding cells
			[coptSub,cx1,ckRSub2,ckCSub2,cmSub2,ckRM1,ckCM1]	= deal(cell(nMultiMax,1));
			[ckRM,ckCM,cx,ckRN,ckCN]							= deal(cell(nMultiMax,1));
			kMulti												= 1;
		end
		
		if ~bDidSomething || nowms>opt.start + opt.timeout
			break;
		end
	end
	
	if bFirst
		progress('action','end');
	end
	if bMulti
		MATLABPoolClose('silent',opt.silent);
	end
