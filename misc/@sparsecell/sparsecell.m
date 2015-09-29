classdef sparsecell
% sparsecell
% 
% Description:	like a sparse array, but for cell arrays
% 
% Syntax:	sc = sparsecell(...) (see cell)
% 
% Updated: 2015-09-23
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		c	= {};
		k	= sparse([]);
		s	= [];
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function sc = sparsecell(varargin)
			%determine the array size
				switch nargin
					case 0
						sc	= sc.setsize([0 0]);
					case 1
						if isscalar(varargin{1})
							sc	= sc.setsize([varargin{1} varargin{1}]);
						else
							sc	= sc.setsize(varargin{1});
						end
					otherwise
						sc	= sc.setsize(cell2mat(varargin));
				end
		end
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		function varargout = subsref(sc,s)
			if numel(s)==1
				assert(~strcmp(s.type,'.'),'Attempt to reference field of non-structure array.');
				
				sz	= cellfun(@numel,s.subs);
				nd	= numel(sz);
				
				cK			= cell(nd,1);
				[cK{1:nd}]	= ndgrid(s.subs{:});
				
				k	= sub2ind(size(sc),cK{:});
				
				kSC	= full(sc.k(k));
				b	= kSC~=0;
				
				switch s.type
					case '{}'
						varargout		= cell(sz);
						varargout(b)	= sc.c(kSC(b));
					case '()'
						x	= sparsecell(sz);
						
						if any(b)
							x	= subsasgn(x,struct('type','()','subs',{{find(b)}}),sc.c(kSC(b)));
						end 
						
						varargout	= {x};
				end
			else
				x	= subsref(sc,s(1));
				
				[varargout{1:nargout}]	= subsref(x,s(2:end));
			end
		end
		
		function sc = subsasgn(sc,s,x)
			if numel(s)==1
				assert(~strcmp(s.type,'.'),'Attempt to reference field of non-structure array.');
				
				sz	= cellfun(@numel,s.subs);
				nd	= numel(sz);
				
				szS	= size(sc);
				
				%check for out of range subscripts
					if nd==1
						kMax	= max(s.subs{1});
						
						if kMax>prod(size(sc))
							bNonSingleton	= szS>1;
							switch sum(bNonSingleton)
								case 0
									dimCheck	= 1;
								case 1
									dimCheck	= find(bNonSingleton);
								otherwise
									error('In an assignment  A(I) = B, a matrix A cannot be resized.');
							end
							
							szS(dimCheck)	= kMax;
							szS(szS==0)		= 1;
							sc				= sc.setsize(szS);
						end
					else
						szS(1:nd)	= max(szS(1:nd),cellfun(@max,s.subs))
						sc			= sc.setsize(szS);
					end	
				
				cK			= cell(nd,1);
				[cK{1:nd}]	= ndgrid(s.subs{:});
				
				k		= sub2ind(szS,cK{:});
				
				kSC	= full(sc.k(k));
				b	= kSC~=0;
				
				nNew		= sum(~b);
				kNew		= numel(sc.c)+(1:nNew);
				kSC(~b)		= kNew;
				sc.k(k(~b))	= kNew;
				
				switch s.type
					case '{}'
						sc.c{kSC}	= x;
					case '()'
						sc.c(kSC)	= x;
				end
			else
				y	= subsref(sc,s(1));
				y	= subsasgn(y,s(2:end),x);
				sc	= subsasgn(sc,s(1),y);
			end
		end
		
		function s = size(sc)
			s	= sc.s;
		end
		
		function n = numel(sc,varargin)
			if ~isempty(varargin)
				n	= numel(sc.c,varargin{:});
			else
				n	= numel(sc.c);
			end
		end
		
		function disp(sc)
			sz	= size(sc);
			nd	= numel(sz);
			
			kEl	= find(sc.k);
			kC	= full(sc.k(kEl));
			n	= numel(kC);
			
			if n==0
				str	= sprintf('   All empty sparse: %s\n',join(sz,'-by-'));
			else
				[cCoord,cValue]	= deal(cell(n,1));
				
				cK	= cell(nd,1);
				for k=1:n
					[cK{1:nd}]	= ind2sub(sz,kEl(k));
					cCoord{k}	= sprintf('(%s)',join(cK,','));
					
					cValue{k}	= StringTrim(evalc('disp(sc.c(kC(k)))'));
				end
				
				wCoord		= max(cellfun(@numel,cCoord));
				strTemplate	= ['%' num2str(wCoord) 's %s'];
				
				[cCoord,kSort]	= sort_nat(cCoord);
				cValue			= cValue(kSort);
				
				cLine	= cellfun(@(c,v) sprintf(strTemplate,c,v),cCoord,cValue,'uni',false);
				str		= join(cLine,10);
			end
			
			disp(str);
		end
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=protected)
		function sc = setsize(sc,sz)
			sc.s	= sz;
			n		= prod(sz);
			nK		= numel(sc.k);
			
			if nK<n
				sc.k(n)	= 0;
			elseif nK>n
				sc.k(n+1:end)	= [];
			end
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
