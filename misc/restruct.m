function s = restruct(s,varargin)
% restruct
% 
% Description:	flip between two ways of storing arrayed data in a struct:
%					1) a struct array / cellnest of uniform structs
%					2) a 1x1 struct of arrays
% 
% Syntax:	s = restruct(s,<options>)
%
% In:
%	s	- a struct as described above
%	<options>:
%		array:	(<auto>) true if we are are going from a struct array to a
%				struct of arrays. this helps resolve ambiguity in cases of
%				struct arrays with one element.
% 
% Updated: 2015-12-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

if isempty(s)
	return;
end

%parse the inputs
	if numel(varargin)==1 && isstruct(varargin{1}) && isfield(varargin{1},'array_size')
		opt	= varargin{1};
	else
		opt	= ParseArgs(varargin,...
				'array'			, []	 ...
				);
		
		if isempty(opt.array)
			opt.array		= numel(s)>1;
		end
		
		if opt.array
			opt.array_size	= size(s);
		else
			opt.array_size	= GetArraySize(s);
		end
	end
	
	if isempty(opt.array_size)
		return;
	end


if iscell(s)
	if isempty(s)
		s	= struct;
		return;
	end
	
	[cf,uf]	= cellnestflatten(s);
	sf		= cell2mat(cf);
	sr		= restruct(sf,'array',true);
	s		= structtreefun(@(x) cellnestunflatten(x,uf),sr);
elseif isstruct(s)
	if opt.array
		s	= Array2Scalar(s,opt);
	else
		s	= Scalar2Array(s,opt);
	end
end

%------------------------------------------------------------------------------%
function s2 = Scalar2Array(s,opt)
	nArray	= prod(opt.array_size);
	
	s2	= repmat(struct,opt.array_size);
	
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	for kF=1:nField
		strField	= cField{kF};
		x			= s.(strField);
		
		if isstruct(x)
			cOpt	= opt2cell(opt);
			x		= restruct(x,cOpt{:});
		end
		
		if isscalar(x) && ~iscell(x)
			[s2(1:nArray).(cField{kF})]	= deal(x);
		else
			szX	= size(x);
			
			if isempty(x)
				x	= {x};
			elseif ~iscell(x) || ~isequal(szX,opt.array_size)
				szSub	= szX./opt.array_size;
				cSzCell	= arrayfun(@(sSub,sX) sSub*ones(sX/sSub,1),szSub,szX,'uni',false);
				x		= mat2cell(x,cSzCell{:});
			end
			
			[s2(1:nArray).(cField{kF})]	= deal(x{:});
		end
	end
%------------------------------------------------------------------------------%
function s2 = Array2Scalar(s,opt)
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	s2	= struct;
	for kF=1:nField
		strField	= cField{kF};
		
		x	= reshape({s.(strField)},opt.array_size);
		if all(reshape(cellfun(@isstruct,x),[],1))
			cOpt	= opt2cell(opt);
			x		= restruct(cell2mat(x),cOpt{:});
		elseif all(reshape(cellfun(@(y) isscalar(y) && ~ischar(y),x),[],1))
			if any(reshape(cellfun(@iscell,x),[],1))
				x	= cellfun(@UnwrapScalarCell,x,'uni',false);
			else
				try
					x	= cell2mat(x);
				end
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
