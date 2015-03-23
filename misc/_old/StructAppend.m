function s = StructAppend(varargin)
% StructAppend
% 
% Description:	append the elements of a set of like-structured tree structs
% 
% Syntax:	s = StructAppend(s1,...,sN,<options>)
%
% In:
%	sK	- the Kth struct
%	<options>:
%		dimension:	(<last occupied dimension>) the dimension along which to
%					append
% 
% Updated: 2010-11-12
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the start of the options
	kOpt	= find(~cellfun(@isstruct,varargin),1,'first');
	if isempty(kOpt)
		kOpt	= nargin+1;
	end
%process the options
	opt	= ParseArgs(varargin(kOpt:end),...
			'dimension'	, []	  ...
			);

if isempty(opt.dimension)
	s	= structtreefun(@append,varargin{:});
else
	s	= structtreefun(@(varargin) cat(opt.dimension,varargin{:}),varargin{:});
end
