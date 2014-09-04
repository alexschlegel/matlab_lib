classdef sparsecell
% sparsecell
% 
% Description:	like a sparse array, but for cell arrays
% 
% Syntax:	sc = sparsecell(m,n,nmax) (see spalloc)
% 
% Updated: 2013-03-10
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		c	= {};
		k	= sparse([]);
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function sc = sparsecell(m,n,nmax)
			sc.k	= spalloc(m,n,nmax);
		end
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		function x = subsref(sc,s)
			if numel(s)==1
				switch s.type
					case '{}'
						k	= sc.k(s.subs{:});
						
						if k~=0
							x	= sc.c{k};
						else
							x	= [];
						end
					case '()'
						error('Unsupported syntax.');
					otherwise
						error('Invalid syntax.');
				end
			else
				x	= subsref(sc,s(1));
				x	= subsref(x,s(2:end));
			end
		end
		function sc = subsasgn(sc,s,x)
			if numel(s)==1
				switch s.type
					case '{}'
						try
							k	= sc.k(s.subs{:});
						catch me
							k	= 0;
						end
						
						if k==0
							k				= numel(sc.c)+1;
							sc.k(s.subs{:})	= k;
						end
						
						sc.c{k}	= x;
					case '()'
						error('Unsupported syntax.');
					otherwise
						error('Invalid syntax.');
				end
			else
				y	= subsref(sc,s(1));
				y	= subsasgn(y,s(2:end),x);
				sc	= subsasgn(sc,s(1),y);
			end
		end
		
		function s = size(sc)
			s	= size(sc.k);
		end
		function disp(sc)
			[x,y]	= find(sc.k);
			n		= numel(x);
			
			[cCoord,cValue]	= deal(cell(n,1));
			
			for k=1:n
				cCoord{k}	= ['  (' num2str(x(k)) ',' num2str(y(k)) ')'];
				cValue{k}	= tostring(sc.c{k});
			end
			
			wCoord	= max(cellfun(@numel,cCoord));
			
			[cCoord,kSort]	= sort_nat(cCoord);
			cValue			= cValue(kSort);
			
			str	= join(cellfun(@(c,v) [StringFill(c,wCoord+1,' ','right') v],cCoord,cValue,'UniformOutput',false),10);
			
			disp(str);
		end
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
