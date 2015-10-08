function s = fill(obj,varargin)
% stimulus.property.collection.fill
% 
% Description:	generated an explicit set of values for the collection's
%				properties
% 
% Syntax: s = fill(obj,<options>)
% 
% In:
%	<options>:
%		value:	({}) a cell array of prop,val pairs specifying new, explicit
%				values for properties. if a given val is empty, then the
%				property value is not set via this mechanism. i.e. this option
%				would be the varargin passed in by the user to specify options.
%		store:	(true) true to store the generated property values, false to
%				keep implicitly defined values implicit
%		
%	[propK]	- the name of the Kth property whose value should be set explicitly
%	[valK]	- the value for propK. if this is empty, the property value is not
%			  set via this mechanism
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'value'	, {}	, ...
			'store'	, true	  ...
			);


s	= struct;

%fill in the explicit values first
	cProp	= opt.value(1:2:end);
	cVal	= opt.value(2:2:end);
	nProp	= numel(cProp);
	
	for kP=1:nProp
		if ~isempty(cVal{kP})
			s.(cProp{kP})	= cVal{kP};
		end
	end

%now fill in the rest from the existing properties
	cProp	= fieldnames(obj.prop);
	nProp	= numel(cProp);

	for kP=1:nProp
		strProp	= cProp{kP};
		
		if ~isfield(s,strProp)
			if opt.store
				s.(strProp)	= subsref(obj,struct('type','.','subs',strProp));
			else
				s.(strProp)	= obj.prop.(strProp).get;
			end
		elseif opt.store
			obj.prop.(strProp)	= obj.prop.(strProp).set(s.(strProp));
		end
	end
