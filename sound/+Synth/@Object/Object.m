classdef Object < Group.Object
% Synth.Object
% 
% Description:	base object for Synth.* objects
% 
% Syntax:	obj = Synth.Object(parent,strType,<options>)
%
% 			methods:
%				<see Group.Object>
%
%			properties:
%				<see Group.Object>
%
% In:
%	parent			- the parent Synth
%	strType			- a fieldname-compatible description of the object type
%	<options>:	see Group.Object
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function obj = Object(parent,strType,varargin)
			obj	= obj@Group.Object(parent,strType,varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
