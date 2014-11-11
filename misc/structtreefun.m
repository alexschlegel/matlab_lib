function varargout = structtreefun(f,varargin)
% structtreefun
% 
% Description:	evaluate a function for each member of a struct tree
% 
% Syntax:	[so1,...,soM] = structtreefun(f,si1,...,siN,<options>)
% 
% In:
% 	f	- the handle to a function that takes N inputs and returns M outputs
%	siK	- the Kth input struct tree (e.g. a.b.c...)
%	<options>:
%		cellreturn:	(false) true to return the results in a cell
%		offset:		(0) evaluate the function on the structs this number of
%					branches from the nearest end of the struct tree
%		omit:		(false) true to omit missing values (i.e. struct fields that
%					occur in some but not all structs), false to substitute them
%		substitute:	([]) the value with which to replace all missing values if
%					the 'omit' option is false
%		silent:	(true) true to suppress status messages
% 
% Out:
% 	siK	- the Kth output struct
% 
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%is this the first or a subsequent function call?
	bFirst	= isa(f,'function_handle');
%parse the inputs
	if bFirst
		%find the first non-struct input
			kOptStart	= find(~cellfun(@isstruct,varargin(1:end)),1,'first');
			if isempty(kOptStart)
				kOptStart	= nargin;
			end
		%split
			cStructIn	= reshape(varargin(1:kOptStart-1),[],1);
			nStructIn	= numel(cStructIn);
			bExist		= true(nStructIn,1);
			
			opt			= ParseArgs(varargin(kOptStart:end),...
							'cellreturn'	, false	, ...
							'offset'		, 0		, ...
							'omit'			, false	, ...
							'substitute'	, []	, ...
							'silent'		, true	  ...
							);
		%get the tree info
			sTree	= cellfun(@(x) TreePathInfo(x,{}),cStructIn,'UniformOutput',false);
	else
		opt							= f;
		[f,cStructIn,sTree,bExist]	= deal(varargin{:});
		nStructIn					= numel(cStructIn);
	end

%call the function or pass the function on?
	nTreeMin	= min(cell2mat(cellfun(@(x) GetFieldPath(x,'n'),sTree,'UniformOutput',false)));
	if isempty(nTreeMin) || nTreeMin<=opt.offset
		%handle missing values
			if opt.omit
				cStructIn(~bExist)	= [];
			else
				cStructIn(~bExist)	= {opt.substitute};
			end
		%evaluate
			[varargout{1:nargout}]	= f(cStructIn{:});
	else
		%get the fields
			bStruct	= cellfun(@isstruct,cStructIn);
			cField	= cellfun(@fieldnames,cStructIn(bStruct),'UniformOutput',false);
			cField	= unique(cat(1,cField{:}));
			nField	= numel(cField);
		%call the function for each struct entry/field
			sStruct	= cellfun(@size,cStructIn,'UniformOutput',false);
			nDim	= cellfun(@numel,sStruct);
			nDimMax	= max(nDim);
			sStruct	= cellfun(@(x) [x ones(1,nDimMax-numel(x))],sStruct,'UniformOutput',false);
			sStruct	= max(cat(1,sStruct{:}),[],1);
			nStruct	= prod(sStruct);
			
			if opt.cellreturn
				cStructOut	= repmat({{}},[nargout 1]);
				cKArgOut	= num2cell(1:nargout);
			else
				cStructOut	= repmat({repmat(struct,sStruct)},[nargout 1]);
			end
			
			for kS=1:nStruct
				for kF=1:nField
					%get the current subfields
						[cStructCur,bExist]	= cellfun(@(x) GetFieldPath(x,kS,cField{kF}),cStructIn,'UniformOutput',false);
						sTreeCur			= cellfun(@(x) GetFieldPath(x,kS,'branch',cField{kF}),sTree,'UniformOutput',false);
					%pass it on
						cFuncOut		= cell(nargout,1);
						[cFuncOut{:}]	= structtreefun(opt,f,cStructCur,sTreeCur,cell2mat(bExist));
					%set the output struct values
						if opt.cellreturn
							cStructOut	= cellfun(@(k,v) [cStructOut{k}; reshape(v,[],1)],cKArgOut,cFuncOut,'UniformOutput',false);
						else
							cStructOut	= cellfun(@(x,v) SetFieldPath(x,kS,cField{kF},v),cStructOut,cFuncOut,'UniformOutput',false);
						end
				end
			end
		
		varargout	= cStructOut;
	end

%------------------------------------------------------------------------------%
function sTree = TreePathInfo(s,cPath)
%get info about a tree's paths
	if isstruct(s) && numel(s)>0
		cField	= fieldnames(s);
		nField	= numel(cField);
		
		sStruct	= size(s);
		nStruct	= numel(s);
		
		sTree	= repmat(struct('path',{cPath}),sStruct);
		
		for kS=1:nStruct
			nMin	= NaN;
			for kF=1:nField
				sTree(kS).branch.(cField{kF})	= TreePathInfo(s(kS).(cField{kF}),[cPath; cField{kF}]);
				nMin							= min(nMin,min([sTree(kS).branch.(cField{kF}).n]));
			end
			
			sTree(kS).n	= nMin+1;
		end
	else
		sTree	= struct('path',{cPath},'n',0,'branch',[]);
	end
%------------------------------------------------------------------------------%

