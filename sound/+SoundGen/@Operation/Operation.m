classdef Operation < handle
% SoundGen.Operation
% 
% Description:	base class for SoundGen.* operation objects
% 
% Syntax:	obj = SoundGen.Operation(parent,type,<options>)
% 
% 			subfunctions:
%				Debug	- return a struct of debug info
% 			 
% 			properties:
%				result			- the result of running the process
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the operation has already run
%				silent			- true if processes should be silent
% 
% In:
%	parent	- the parent SoundGen.System object
%	type	- the operation type.  one of: 'segmenter','clusterer','generator',
%			  'exemplarizer', or 'concatenater'
%	<options>:
%		silent:	(<parent value>) true if processes should be silent
%
% Updated: 2012-11-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		result	= [];
		
		parent	= [];
		
		ran		= false;
		silent	= [];
	end
	properties (SetAccess=protected)
		type			= '';
		intermediate	= struct;
		debug			= [];
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		parentran	= '';
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function obj = set.result(obj,res)
			if isempty(res)
				obj.result			= [];
				obj.intermediate	= struct;
				
				obj.parent.(obj.parentran)	= false;
			else
				obj.result	= res;
			end
		end
		
		function obj = set.ran(obj,b)
			if ~b && obj.ran
				obj.result	= [];
				obj.debug	= [];
			elseif b && ~obj.ran
				error('Set result to make this property ''true''.');
			end
		end
		function b = get.ran(obj)
			b	= ~isempty(obj.result);
		end
		
		function b = get.silent(obj)
			b	= unless(obj.silent,obj.parent.silent);
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function obj = Operation(parent,type,varargin)
			obj.parent	= parent;
			
			opt	= ParseArgs(varargin,...
					'silent'	, []	  ...
					);
			
			cType	=		{
								'segmenter'
								'clusterer'
								'generator'
								'exemplarizer'
								'concatenater'
							};
			cParentRan	=	{
								'segmented'
								'clustered'
								'generated'
								'exemplarized'
								'concatenated'
							};
			
			obj.type		= CheckInput(type,'type',cType);
			kType			= FindCell(cType,obj.type);
			obj.parentran	= cParentRan{kType};
			
			obj.silent	= opt.silent;
		end
	end
	methods (Static)
		
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=protected)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
