classdef Color < PTB.Object
% PTB.Color
% 
% Description:	use to store/retrieve colors
% 
% Syntax:	col = PTB.Color(parent)
% 
% 			subfunctions:
%				Start(<options>):	start the object
%				End:				end the object
%				Get:				get an [r g b a] color
%				Set:				set a named color
% 
% In:
%	parent	- the parent object
% 	<options>:
%		custom_color:	(struct) a struct specifying custom colors.  field names
%						give color names and values give color values
% 
% Updated: 2011-12-18
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function col = Color(parent)
			col	= col@PTB.Object(parent,'color');
		end
		%----------------------------------------------------------------------%
		function Start(col,varargin)
			opt	= ParseArgs(varargin,...
					'custom_color'	, struct	  ...
					);
			
			%get the single colors from str2rgb
				colDefault	= str2rgb;
				colName		= fieldnames(colDefault);
				nColDefault	= numel(colName);
				for kC=1:nColDefault
					strCol	= colName{kC};
					
					if ~isa(colDefault.(strCol),'double') || size(colDefault.(strCol),1)>1
						colDefault	= rmfield(colDefault,strCol);
					end
				end
				colDefault	= structfun2(@(col) double(im2uint8(col)),colDefault);
			%add some extras
				colDefault.none	= [0 0 0 0];
			
			cols	= StructMerge(colDefault,opt.custom_color);
			
			cField	= fieldnames(cols);
			nField	= numel(cField);
			for kF=1:nField
				col.Set(cField{kF},cols.(cField{kF}),'replace',false);
			end
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
