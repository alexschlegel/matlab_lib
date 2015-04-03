function s = restruct(s,varargin)
% restruct
% 
% Description:	flip between two ways of storing arrayed data in a struct:
%					1) a struct array / cellnest of uniform structs
%					2) a 1x1 struct of arrays
% 
% Syntax:	s = restruct(s)
% 
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the array size
	szArray	= ParseArgs(varargin,[]);
	
	if isempty(szArray)
		szArray	= GetArraySize(s);
	end
	
	if isempty(szArray)
		return;
	end


if iscell(s)
	[cf,uf]	= cellnestflatten(s);
	sf		= cell2mat(cf);
	sr		= restruct(sf);
	s		= structtreefun(@(x) cellnestunflatten(x,uf),sr);
elseif isstruct(s)
	if numel(s)==1
		s	= Scalar2Array(s,szArray);
	else
		s	= Array2Scalar(s,szArray);
	end
end

%------------------------------------------------------------------------------%
function s2 = Scalar2Array(s,szArray)
	nArray	= prod(szArray);
	
	s2	= repmat(struct,szArray);
	
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	for kF=1:nField
		strField	= cField{kF};
		x			= s.(strField);
		
		if isstruct(x)
			x	= restruct(x,szArray);
		end
		
		if isscalar(x) && ~iscell(x)
			[s2(1:nArray).(cField{kF})]	= deal(x);
		else
			szX	= size(x);
			
			if ~iscell(x) || ~isequal(szX,szArray)
				szSub	= szX./szArray;
				cSzCell	= arrayfun(@(sSub,sX) sSub*ones(sX/sSub,1),szSub,szX,'uni',false);
				x		= mat2cell(x,cSzCell{:});
			end
			
			[s2(1:nArray).(cField{kF})]	= deal(x{:});
		end
	end
%------------------------------------------------------------------------------%
function s2 = Array2Scalar(s,szArray)
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	s2	= struct;
	for kF=1:nField
		strField	= cField{kF};
		
		x	= reshape({s.(strField)},szArray);
		if all(reshape(cellfun(@isstruct,x),[],1))
			x	= restruct(cell2mat(x),szArray);
		elseif all(reshape(cellfun(@(y) isscalar(y) && ~ischar(y),x),[],1))
			if any(reshape(cellfun(@iscell,x),[],1))
				x	= cellfun(@UnwrapScalarCell,x,'uni',false);
			else
				x	= cell2mat(x);
			end
		%elseif all(cellfun(@iscell,x))
		%	x	= cell2mat2(x);
		end
		
		s2.(strField)	= x;
	end
%------------------------------------------------------------------------------%
function x = UnwrapScalarCell(x) 
	if iscell(x)
		x	= x{1};
	end
%------------------------------------------------------------------------------%
function sz = GetArraySize(s) 
	if isstruct(s)
		if numel(s)==1
			%get the size of each non-scalar field
				sz	= struct2cell(structfun(@GetArraySize,s,'uni',false));
				sz	= sz(~cellfun(@(x) isequalwithequalnans(x,NaN),sz));
				nd	= max(cellfun(@numel,sz));
				sz	= cellfun(@(s) [s ones(nd-numel(s))],sz,'uni',false);
				sz	= cat(1,sz{:});
				
				nSz		= size(sz,1);
				if nSz>0
					szGCD	= sz(1,:);
					for kS=2:nSz
						szGCD	= gcd(szGCD,sz(kS,:));
					end
					sz	= szGCD;
				end
		else
			sz	= size(s);
		end
	elseif isscalar(s) && ~iscell(s)
		sz	= NaN;
	else
		sz	= size(s);
	end
%------------------------------------------------------------------------------%