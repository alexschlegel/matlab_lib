classdef Collection < Group.Object
% Group.Collection
% 
% Description:	base object for collecting and combining Group.Objects
% 
% Syntax:	col = Group.Collection(parent,[strType]=<auto>,strClass,<options>)
%			col('mem1','mem2',...).func(...)
%
% 			methods:
%				<see Group.Object>
%				Add:		add members to the collection
%				Remove:		remove members from the collection
%
%			properties:
%				<see Group.Object>
%				members:	a cell of member names
%
% In:
%	parent		- the parent object
%	[strType]	- a fieldname-compatible description of the object type
%	strClass	- the class name of the Group.Objects that will be combined in
%				  the collection
%	<options>:
%		<see Group.Object>
% 
% Updated: 2011-12-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties (SetAccess=protected)
		members;
		collection;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		p_class;
	end
	properties (Abstract, SetAccess=protected, GetAccess=protected)
		%an Nx2 cell defining how to combine properties and methods of the
		%member objects.  the first column is the name of the property/method
		%and the second is a function that takes arbitrary arguments and
		%combines them
			combine;
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function col = Collection(parent,strType,strClass,varargin)
			strType	= unless(strType,[lower(strClass) 's']);
			col		= col@Group.Object(parent,strType,varargin{:});
			
			col.p_class	= strClass;
		end
		%----------------------------------------------------------------------%
		function Start(col,varargin)
			col.argin	= append(col.argin,varargin);
			
			%set some info
				col.Info.Set('collection_class',col.p_class,false);
			
			%start the attached objects
				cellfun(@(x) x.Start(col.argin{:}),col.children);
			%add the objects from the info struct
				ifo	= col.Info.Get('collection_add');
				if ~isempty(ifo)
					cellfun(@(x) col.Add(x{:},col.argin{:}),ifo);
				end
			
			Start@Group.Object(col,varargin{:});
		end
		%----------------------------------------------------------------------%
		function End(col,varargin)
			obj.started	= false;
			
			%end the attached objects
				cellfun(@(x) x.End(varargin{:}),col.children(end:-1:1));
			%end the collection members
				objfun(@(x) x.End(varargin{:}),col.collection(end:-1:1));
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%OVERLOADED METHODS--------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function varargout = subsref(col,s)
			switch s(1).type
				case '()'
				%reference to collection members
					%get the member positions
					[b,k]	= ismember(s(1).subs,col.members);
					k		= k(b);
					n		= numel(k);
					
					%get the output from each member
						if numel(s)>1
							[varargout{1:nargout}]	= objfun(@(x) subsref(x,s(2:end)),col.collection(k),'UniformOutput',false);
							
							%combine
								[bSub,kSub]	= ismember(s(2).subs,col.combine(:,1));
								
								if bSub
									varargout	= cellfun(col.combine{kSub,2},varargout,'UniformOutput',false);
								end
						else
							varargout{1}	= col.collection(k);
						end
				case '.'
					if ismember(s(1).subs,methods(col))
						[varargout{1:nargout}]	= col.(s(1).subs)(s(2).subs{:});
					else
						if numel(s)>1
							[varargout{1:nargout}]	= subsref(col.(s(1).subs),s(2:end));
						else
							varargout{1}	= col.(s(1).subs);
						end
					end
				case '{}'
					error('Invalid syntax.');
			end
		end
		%----------------------------------------------------------------------%
	end
	%OVERLOADED METHODS--------------------------------------------------------%
end
