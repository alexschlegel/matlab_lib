classdef chimp < stimulus.image.base
% stimulus.image.mentalrotation.chimp
% 
% Description:	create a figure used for the chimp mental rotation study
% 
% Syntax: obj = stimulus.image.mentalrotation.chimp([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				figure: (<random>) the figure number (1-80)
%				tx: ('') a string specifying the transformations to perform on
%					the figure. takes the form
%					'<x1>[<n1>] <x2>[<n2>] ... <xN>[<nN>]', where <xK> is the
%					operation and possible <nK> is the parameter for the
%					operation. possible operations are:
%						R:	rotate nK degrees
%						FH:	flip horizontally (no parameter)
%						FV:	flip vertically (no parameter)
%					e.g. 'R-90 FH' rotate -90 degrees then flip horizontally
%			<see also stimulus.image.base>
% 
% In:
%	[paramK]	- the Kth parameter whose value should be set explicitly
%	[valK]		- the explicit value of parameter paramK (or empty to skip
%				  skip setting the value)
% 
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%CONSTANT
		properties (Constant, GetAccess=protected)
			N_FIGURE	= 80;
		end
	
	%PRIVATE
		properties (SetAccess=protected, GetAccess=protected)
			stim_param;
		end
%/PROPERTIES--------------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = chimp(varargin)
				obj = obj@stimulus.image.base();
				
				%set some parameter defaults
					add(obj.param,'figure','list',{1:obj.N_FIGURE});
					add(obj.param,'tx','generic',{''});
				
				%parse the inputs
					obj.parseInputs(varargin{:});
				
				%get the stimulus parameters
					obj.stim_param	= obj.get_stimulus_parameters;
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			[mask,ifo] = generate_mask(obj,ifo)
			param = get_stimulus_parameters(obj)
		end
%/METHODS-----------------------------------------------------------------------

end
