classdef mapping
% mapping
% 
% Description:	an object to map anything to anything else
% 
% Syntax:	m = mapping(cDomain,cRange,<options>)
%			y = m(x)					: return what x maps to
%			y = m(x1,...,xN)			: return a cell of mapped values
%			[y1,...,yk] = m{x1,...,xN} : return several mapped values
%			m(x) = y					: map x to y
%			m{x1,...,xN} = {y1,...,yN}	: map xK to yK
%			m(x1,...,xN) = y			: map xK to y
%			m = m1 + m2					: merge two mappings (m2 overwrites m1)
%			m = m1 - m2					: remove the domain of m2 from the domain
%										  of m1
%			m = m - x					: remove x from the domain of m
%			
%			subfunctions:
%				[b,y,k] = m.maps(x)	: is x in the domain?
%				[b,x] = m.mapped(y)	: is y in the range?
%				
%			properties:
%				m.domain (get)
%				m.range (get)
%				m.n (get)
%				m.complete (get/set)
%				m.metric (get/set)
%				m.interp (get/set)
% 
% In:
% 	cDomain	- a cell of elements defining the initial domain of the mapping
%	cRange	- a cell the same size as cDomain defining the initial range of the
%			  mapping
%	<options>:
%		mapindex:	(false) true if integer inputs should be treated as indices
%					in the domain cell
%		complete:	(false) true if everything should map to something.  if true,
%					the mapping will match inputs to explicitly-defined domain
%					members based on a metric and then map to its output based
%					on an interpolation method.
%		metric:		(<depends on domain type>) one of the following to specify
%					the metric for matching in complete mappings:
%						euclidean:	default for domains of same-sized arrays;
%							arrays are matched based on euclidean distance
%						alphanumeric:	default for domains of strings; strings
%							are matched based on alphanumeric sorting
%						size:	default for arbitrary domains; elements are
%							matched based on size, in bytes
%						<f>:	the handle to a function that takes two inputs
%							and returns a scalar
%		interp:		('nn') the interpolation method to use when assigning range
%					values to implicitly-defined inputs.  one of the following:
%						nn:	nearest neighbor interpolation
%						<f>:	the handle to a function that takes the range and
%							a numeric array representing the distance of an
%							element from each member of the domain as input and
%							returns an interpolated range value
% 
% Updated: 2011-12-05
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	properties
		domain;		%the set of explicitly defined inputs
		range;		%the set of explicitly defined outputs
		complete;	%logical, is this a complete mapping?
		metric;		%the metric to use for matching in complete mappings
		interp;		%the interpolation method to use for assigning range values
					%in complete mappings
		n;			%the number of mapping pairs
		mapindex;	%true to map integers as indices in the domain cell
	end
	
	properties (SetAccess=private, GetAccess=private)
		%store the actual domain, range, and keys of each mapping element
			p_domain;
			p_range	= {};
			p_key	= [];
		
		p_n	= 0;	%number of elements in the mapping
		
		p_domain_type			= -1;			%code specifying the domain type
		p_domain_array_size;					%array size for DOMAIN_ARRAY type
		
		
		p_default_metric	= true;	%true if the user hasn't specified a metric
		
		%codes for each method of storing domain elements
			DOMAIN_ANY		= 0; %store arbitrary elements
			DOMAIN_CHAR		= 1; %store character arrays
			DOMAIN_ARRAY	= 2; %store uniformly-sized numeric arrays
	end
	
	
	%PROPERTY GET/SET-----------------------------------------------------------
	methods
		function cDomain = get.domain(m)
		%return the domain of the mapping
			switch m.p_domain_type
				case {m.DOMAIN_ANY,m.DOMAIN_CHAR}
					cDomain	= m.p_domain;
				case m.DOMAIN_ARRAY
				%store the domain elements in a cell
					warning('off','MATLAB:mat2cell:TrailingUnityVectorArgRemoved');
					
					sz		= num2cell(m.p_domain_array_size);
					cDomain	= reshape(m.p_domain,[m.p_domain_array_size m.p_n]);
					cDomain	= squeeze(mat2cell(cDomain,sz{:},ones(m.p_n,1)));
				otherwise
					cDomain	= {};
			end
		end
		function cRange = get.range(m)
		%return the range of the mapping
			cRange	= m.p_range;
		end
		function n = get.n(m)
		%return the number of elements in the mapping
			n	= m.p_n;
		end
		function m = set.metric(m,met)
		%set the metric for mapping implicit domain elements
			m.p_default_metric	= false;
			m.metric			= met;
		end
	end
	%PROPERTY GET/SET-----------------------------------------------------------
	
	
	%PUBLIC METHODS-------------------------------------------------------------
	methods
		function m = mapping(varargin)
		%class constructor
			[cDomain,cRange,opt]	= ParseArgs(varargin,{},{},...
										'mapindex'	, false	, ...
										'complete'	, false	, ...
										'metric'	, []	, ...
										'interp'	, 'nn'	  ...
										);
			
			m.mapindex	= opt.mapindex;
			m.complete	= opt.complete;
			m.metric	= opt.metric;
			m.interp	= opt.interp;
			
			m.p_default_metric	= isempty(m.metric);
			
			if ~isempty(cDomain)
			%define the mapping
				cDomain	= reshape(ForceCell(cDomain),[],1);
				cRange	= reshape(ForceCell(cRange),[],1);
				
				m	= m.p_Map(cDomain,cRange);
			end
		end
		function [b,cTo,k] = maps(m,cFrom,varargin)
		%do elements in cFrom map?
			bExplicit	= ParseArgs(varargin,false);
			
			cFrom	= ForceCell(cFrom);
			
			if m.mapindex && all(cellfun(@(x) isnumeric(x) && isint(x) && x>=1 && x<=m.n,cFrom))
				b	= true(size(cFrom));
				k	= cell2mat(cFrom);
				cTo	= m.p_range(k);
				
				return;
			end
			
			sz		= size(cFrom);
			b		= false(sz);
			cTo		= cell(sz);
			k		= zeros(sz);
			
			switch m.p_domain_type
				case m.DOMAIN_ANY
					bCheck	= true(size(cFrom));
					
					keyFrom	= m.p_Key(cFrom);
					nFrom	= numel(cFrom);
					
					for kF=1:nFrom
						%only check elements with the same key
							kCheck	= find(m.p_key==keyFrom(kF));
						
						kMatch	= FindCell(m.p_domain(kCheck),cFrom{kF},1);
						
						if ~isempty(kMatch)
							b(kF)	= true;
							k(kF)	= kCheck(kMatch);
						end
					end
				case m.DOMAIN_CHAR
					%only check char arrays
						bCheck	= cellfun(@(x) isa(x,'char'),cFrom);
					
					[b(bCheck),k(bCheck)]	= ismember(cFrom(bCheck),m.p_domain);
				case m.DOMAIN_ARRAY
					%only check numeric arrays of the correct size
						bCheck	= cellfun(@(x) isnumeric(x) && isequal(size(x),m.p_domain_array_size),cFrom);
						kCheck	= find(bCheck);
						nCheck	= numel(kCheck);
					
					for kC=1:nCheck
						%elementwise check of current array against domain arrays 
							kCur	= kCheck(kC);
							fCur	= repmat(reshape(cFrom{kCur},[],1),[1 m.p_n]);
							kMatch	= find(all(m.p_domain==fCur,1),1);
						
						if ~isempty(kMatch)
							b(kCur)		= true;
							k(kCur)		= kMatch;
						end
					end
			end
			
			%assign the range elements that matched
				cTo(b)	= m.p_range(k(b));
			
			if any(~b(:)) && ~bExplicit && m.complete
			%make implicit matches
				%only match correctly formatted, unmatched elements
					kMatch	= find(~b & bCheck);
					cMatch	= cFrom(kMatch);
				
				switch class(m.metric)
					case 'function_handle'
					%arbitrary function that takes two inputs and returns a
					%scalar
						d	= cellfun(@(cM) cellfun(@(cD) m.metric(cM,cD),m.p_domain),cMatch,'UniformOutput',false);
					case 'char'
						switch lower(m.metric)
							case 'euclidean'
							%euclidean distance between two arrays
								d	= cellfun(@(x) dist(m.p_domain',reshape(x,1,[])),cMatch,'UniformOutput',false);
							case 'alphanumeric'
							%alphanumeric sort distance
								%find where we would insert the string
									sc		= cellfun(@(str) cellfun(@(strR) StringCompare(strR,str),m.p_domain),cMatch,'UniformOutput',false);
									kInsert	= cellfun(@(x) unless(find(x==1,1,'first')-1,m.p_n),sc);
								%distance from that point
									d		= arrayfun(@(k) abs((1:m.p_n) - k),kInsert,'UniformOutput',false);
							case 'size'
							%distance based on variable size, in bytes
								d	= cellfun(@(x) abs(m.p_Key({x}) - m.p_key),cMatch,'UniformOutput',false);
							otherwise
								error(['Invalid metric.']);
						end
					otherwise
						error(['Invalid metric.']);
				end
				
				switch class(m.interp)
					case 'function_handle'
					%arbitrary function that takes the range values and distances
					%between domain and element and returns an interpolated
					%range value
						cTo(kMatch)	= cellfun(@(dCur) m.interp(m.p_range,dCur),d,'UniformOutput',false);
					case 'char'
						switch lower(m.interp)
							case 'nn'
							%just take the range value of the nearest domain
							%match
								cTo(kMatch)	= cellfun(@(dCur) m.p_range{find(dCur==min(dCur),1)},d,'UniformOutput',false);
							otherwise
								error(['Invalid interp method.']);
						end
					otherwise
						error(['Invalid interp method.']);
				end
			end
		end
		function [b,varargout] = mapped(m,cTo)
		%do the elements of cTo get mapped to?
			cTo		= ForceCell(cTo);
			kFrom	= cellfun(@(x) unless(FindCell(m.p_range,x,1),0),cTo);
			
			b	= kFrom~=0;
			
			if nargout>1
			%return the domain elements mapping to the elements of cTo
				cFrom	= cell(size(cTo));
				
				switch m.p_domain_type
					case {m.DOMAIN_ANY,m.DOMAIN_CHAR}
						cFrom(b)	= m.p_domain(kFrom(b));
					case m.DOMAIN_ARRAY
						warning('off','MATLAB:mat2cell:TrailingUnityVectorArgRemoved');
						
						%convert domain arrays to a cell
							nFound		= sum(b);
							sz			= num2cell(m.p_domain_array_size);
							xFrom		= reshape(m.p_domain(:,kFrom(b)),[m.p_domain_array_size nFound]);
							cFrom(b)	= squeeze(mat2cell(xFrom,sz{:},ones(nFound,1))); 
				end
				
				varargout{1}	= cFrom;
			end
		end
	end
	%PUBLIC METHODS-------------------------------------------------------------
	
	
	%OVERLOADED FUNCTIONS-------------------------------------------------------
	methods
		function m = plus(m1,m2)
		%combine the contents of two maps
			m	= m1.p_Map(m2.domain,m2.range);
		end
		function m = minus(m1,m2)
		%remove elements from a mapping
			switch class(m2)
				case 'mapping'
				%remove elements of another mapping
					m	= m1.p_Remove(m2.domain);
				otherwise
				%remove an element directly
					m	= m1.p_Remove({m2});
			end
		end
		function varargout = subsref(m,s)
			switch s(1).type
				case '()'
				%fetch mapped values, one output
					if numel(s)>1
						error('Unsupported syntax.');
					end
					
					[b,cTo]	= m.maps(s.subs);
					
					if numel(s.subs)==1
						varargout{1}	= cTo{1};
					else
						varargout{1}	= cTo;
					end
				case '{}'
				%fetch mapped values, multiple outputs
					if numel(s)>1
						error('Unsupported syntax.');
					end
					
					[b,cTo]	= m.maps(s.subs);
					
					[varargout{1:nargout}]	= deal(cTo{1:nargout});
				case '.'
				%submethod or property get
					if numel(s)>1
						[varargout{1:nargout}]	= m.(s(1).subs)(s(2).subs{:});
					else
						[varargout{1:nargout}]	= m.(s(1).subs);
					end
				otherwise
					error('Unsupported syntax.');
			end
		end
		function m = subsasgn(m,s,cTo)
			if numel(s)>1
				error('Unsupported syntax.');
			end
			
			switch s.type
				case '()'
				%map domain elements to a single range value
					nFrom	= numel(s.subs);
					cTo		= repmat({cTo},[nFrom 1]);
					s.subs	= reshape(s.subs,[],1);
					m		= m.p_Map(s.subs,cTo);
				case '{}'
				%map domain elements to range values
					cTo		= reshape(ForceCell(cTo),[],1);
					s.subs	= reshape(s.subs,[],1);
					m		= m.p_Map(s.subs,cTo);
				case '.'
				%set a property
					switch s(1).subs
						case {'domain','range','n'}
							error(['"' s(1).subs '" is not a settable property.']);
						otherwise
							m.(s(1).subs)	= cTo;
					end
				otherwise
					error('Unsupported syntax.');
			end
		end
	end
	%OVERLOADED FUNCTIONS-------------------------------------------------------
	
	
	%PRIVATE METHODS------------------------------------------------------------
	methods (Access=private)
		function m = p_Map(m,cFrom,cTo)
		%set mapping pairs
			%find out which from elements already map
				[bMaps,cToOld,kMaps]	= m.maps(cFrom,true);
			%remap them
				m	= m.p_Remap(kMaps(bMaps),cTo(bMaps));
			%add the new elements
				m	= m.p_Add(cFrom(~bMaps),cTo(~bMaps));
		end
		function m = p_Remap(m,kMap,cTo)
		%reassign domain elements to a new range value.  these must already
		%exist.
			m.p_range(kMap)	= cTo;
		end
		function m = p_Add(m,cFrom,cTo)
		%add mapping pairs.  these must not already exist.
			if isempty(cFrom) || isempty(cTo)
				return;
			end
			
			switch m.p_domain_type
				case m.DOMAIN_ANY
					bConsistent	= true;
				case m.DOMAIN_CHAR
					%did we get all chars?
						bConsistent	= all(cellfun(@ischar,cFrom));
				case m.DOMAIN_ARRAY
					sz	= cellfun(@size,cFrom,'UniformOutput',false);
					nd	= cellfun(@numel,sz);
					n	= numel(nd);
					
					%did we get all correctly-sized numeric arrays?
						bConsistent	= all(cellfun(@isnumeric,cFrom)) && all(nd==numel(m.p_domain_array_size)) && all(all(cat(1,sz{:})==repmat(m.p_domain_array_size,[n 1])));
				otherwise
				%domain type hasn't been set yet
					bConsistent	= true;
					
					if all(cellfun(@isnumeric,cFrom))
					%all numeric arrays?
						sz	= cellfun(@size,cFrom,'UniformOutput',false);
						nd	= cellfun(@numel,sz);
						n	= numel(nd);
						
						if all(nd==nd(1)) && all(all(cat(1,sz{:})==repmat(sz{1},[n 1])))
						%all the same size?
							m	= m.p_SetDomainType(m.DOMAIN_ARRAY);
						else
						%nope, arbitrary mapping
							m	= m.p_SetDomainType(m.DOMAIN_ANY);
						end
					elseif all(cellfun(@ischar,cFrom))
					%all character arrays?
						m	= m.p_SetDomainType(m.DOMAIN_CHAR);
					else
					%arbitrary mapping
						m	= m.p_SetDomainType(m.DOMAIN_ANY);
					end
			end
			
			if bConsistent
			%new elements are consistent with the existing domain type
				m.p_range	= append(m.p_range,cTo);
				m.p_key		= append(m.p_key,m.p_Key(cFrom));
				m.p_n		= m.p_n + numel(cFrom);
				
				switch m.p_domain_type
					case m.DOMAIN_ANY
						m.p_domain	= append(m.p_domain,cFrom);
					case m.DOMAIN_CHAR
					%add the new strings and (don't) sort
						m.p_domain	= append(m.p_domain,cFrom);
% 						[m.p_domain,kSort]	= sort(append(m.p_domain,cFrom));
% 						m.p_range			= m.p_range(kSort);
% 						m.p_key				= m.p_key(kSort);
					case m.DOMAIN_ARRAY
						if isempty(m.p_domain) && ~isempty(cFrom)
						%get the size of each domain array
							m.p_domain_array_size	= size(cFrom{1});
						end
						
						%store as Nx1 arrays
							cFrom		= cellfun(@(x) reshape(x,[],1),cFrom,'UniformOutput',false);
							m.p_domain	= [m.p_domain cFrom{:}];
				end
			else
			%inconsistent additions, switch to arbitrary domain type
				m	= m.p_Recast(m.DOMAIN_ANY);
				m	= m.p_Add(cFrom,cTo);
			end
		end
		function m = p_Remove(m,cFrom)
		%remove elements from the mapping.  these don't need to exist already.
			[bMaps,cTo,kMaps]	= m.maps(cFrom,true);
			kMaps				= kMaps(bMaps);
			
			m.p_range(kMaps,:)	= [];
			m.p_key(kMaps,:)	= [];
			
			m.p_n				= numel(m.p_range);
			
			switch m.p_domain_type
				case {m.DOMAIN_ANY,m.DOMAIN_CHAR}
					m.p_domain(kMaps)	= [];
				case m.DOMAIN_ARRAY
					m.p_domain(:,kMaps)	= [];
			end
		end
		function m = p_Recast(m,domain_type);
		%switch domain types
			switch domain_type
				case {m.DOMAIN_ANY,m.DOMAIN_CHAR}
					switch m.p_domain_type
						case m.DOMAIN_ARRAY
							warning('off','MATLAB:mat2cell:TrailingUnityVectorArgRemoved');
							
							%reshape to array size and add to a cell
								sz			= num2cell(m.p_domain_array_size);
								m.p_domain	= reshape(m.p_domain,[m.p_domain_array_size m.p_n]);
								m.p_domain	= squeeze(mat2cell(m.p_domain,sz{:},ones(m.p_n,1)));
					end
				case m.DOMAIN_ARRAY
					switch m.p_domain_type
						case {m.DOMAIN_ANY, m.DOMAIN_CHAR}
							m.p_domain	= stack(m.p_domain{:});
					end
			end
			
			m	= m.p_SetDomainType(domain_type);
		end
		function m = p_SetDomainType(m,dType)
		%set the domain type, possibly changing the metric
			switch dType
				case m.DOMAIN_ANY
					if isempty(m.p_domain)
						m.p_domain	= {};
					end
					
					m.p_domain_type	= m.DOMAIN_ANY;
					
					if m.p_default_metric
						m.metric			= 'size';
						m.p_default_metric	= true;
					end
				case m.DOMAIN_CHAR
					if isempty(m.p_domain)
						m.p_domain	= {};
					end
					
					m.p_domain_type	= m.DOMAIN_CHAR;
					
					if m.p_default_metric
						m.metric			= 'alphanumeric';
						m.p_default_metric	= true;
					end
				case m.DOMAIN_ARRAY
					if isempty(m.p_domain)
						m.p_domain	= [];
					end
					
					m.p_domain_type	= m.DOMAIN_ARRAY;
					
					if m.p_default_metric
						m.metric			= 'euclidean';
						m.p_default_metric	= true;
					end
			end
		end
		function key = p_Key(m,cFrom)
		%key to speed up matching with arbitraty domain type
			key	= cellfun(@varsize,cFrom);
		end
	end
	%PRIVATE METHODS------------------------------------------------------------
end
