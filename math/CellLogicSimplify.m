function c = CellLogicSimplify(c,varargin)
% CellLogicSimplify
% 
% Description:	denest and simplify a nested cell representing a logical
%				combination of elements, where Nx1 subcells indicate AND
%				statements and 1xN cells inidicate OR statements.  For example,
%				the cell:
%					{{A,B};{C,{A;D;E}}}
%				represents the statement:
%					(A|B)&(C|(A&D&E))
%				and would be become:
%					(A&C)|(A&D&E)|(B&C) =>
%					{{A;C},{A;D;E},{B,C}}
% 
% Syntax:	cSimple = CellLogicSimplify(cNest)
%
% Out:
%	c	- a 1xN cell of []x1 cells of non-cell elements, representing a single
%		  (A&B&C&...)|(D&E&F&...)|(G&H&I&...)|...-type statement
% 
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent	nLevel;

nLevel	= unless(nLevel+1,1);

if iscell(c)
	if any(cellfun(@iscell,c)) || size(c,1)>1
		switch numel(c)
			case 0
			%empty cell
			case 1
			%single-element cell
				c	= CellLogicSimplify(c{1});
			otherwise
			%compound statement
				%process each sub cell
					c	= cellfun(@CellLogicSimplify,c,'UniformOutput',false);
				%now combine into a single string of AND grouped with ORs
					s	= size(c);
					if s(1)>1
					%AND statement, expand
						cNew	= c{1};
						for k=2:numel(c)
							cNew	= CLS_Distribute(cNew,c{k});
						end
						c	= cNew;
					else
					%OR statement, concatenate
						cNew	= ForceCell(c{1},'level',2);
						for k=2:numel(c)
							n	= numel(c{k});
							s	= size(c{k});
							if s(1)>1 || n==1
							%single AND
								cNew	= [cNew ForceCell(c{k},'level',2)];
							elseif n>0
							%all ORs
								cNew	= [cNew c{k}];
							end
						end
						c	= cNew;
					end
				%remove elements that contain subsets of others
				%e.g. A&B&C | A&B = A&B
					k1=1;
					while k1<numel(c)
						k2=k1+1;
						while k2<=numel(c)
							if CLS_IsIn(c{k1},c{k2})
								c(k2)	= [];
							elseif CLS_IsIn(c{k2},c{k1})
								c(k1)	= [];
								k1		= k1-1;
								break;
							else
								k2	= k2+1;
							end
						end
						
						k1	= k1+1;
					end
		end
	elseif size(c,1)==1
		c	= cellfun(@CLS_ToCell,c,'UniformOutput',false);
	end
else
	c	= CLS_ToCell(c);
end

nLevel	= nLevel-1;
if nLevel==0 && numel(c)==1 && ~iscell(c{1})
	c	= {c};
end

%------------------------------------------------------------------------------%
function c = CLS_ToCell(c)
	if isnumeric(c)
		c	= num2cell(c);
	else
		c	= {c};
	end
end
%------------------------------------------------------------------------------%
function z = CLS_Distribute(x,y)
% x and y are 1xN cells of Mx1 cells
	if isempty(x)
		z	= y;
	elseif isempty(y)
		z	= x;
	else
		nX	= numel(x);
		nY	= numel(y);
		nZ	= nX*nY;
		
		z	= cell(1,nZ);
		for kX=1:nX
			for kY=1:nY
				kZ		= nY*(kX-1) + kY;
				if iscell(x{kX})
					if iscell(y{kY})
						z{kZ}	= [x{kX}; y{kY}];
					else
						z{kZ}	= [x{kX}; y(kY)];
					end
				else
					z{kZ}	= [x(kX); y(kY)];
				end
			end
		end
	end
end
%------------------------------------------------------------------------------%
function b = CLS_IsIn(x,y)
% test if all the elements of x are in y
	numX	= isnumeric(x);
	numY	= isnumeric(y);
	if numX && numY
		b	= isempty(setdiff(x,y));
	else
		cX	= class(x);
		cY	= class(y);
		
		switch cX
			case 'cell'
				switch cY
					case 'cell'
					%check if all elements of x are in y
						nX	= numel(x);
						nY	= numel(y);
						b	= false;
						
						for kX=1:nX
							b	= false;
							for kY=1:nY
								if isequal(x{kX},y{kY})
									b	= true;
									break;
								end
							end
							
							if ~b
								return;
							end
						end
					otherwise
					%cell can't be in non-cell
						b	= false;
				end
			otherwise
				switch cY
					case 'cell'
					%see if x is in cell y
						nY	= numel(y);
						b	= false;
						
						for kY=1:nY
							if isequal(x,y{kY})
								b	= true;
								break;
							end
						end
					otherwise
					%test for equality of x and y
						b	= isequal(x,y);
				end
		end
	end
end
%------------------------------------------------------------------------------%

end
