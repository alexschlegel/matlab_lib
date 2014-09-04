classdef Oscillators < Synth.Object & Group.Collection
% Synth.Oscillators
% 
% Description:	a collection of oscillators
% 
% Syntax:	oscs = Synth.Oscillators(parent,<options>)
% 
% 			subfunctions:
%				<see Synth.Oscillator and Group.Collection>
%
%			properties:
%				<see Synth.Oscillator and Group.Collection>
% 
% In:
%	parent		- the parent object
% 	<options>:	see Group.Collection
% 
% Updated: 2011-12-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		combine	=	{
						'rate'		,	@(v) v{1}
						'Generate'	,	@(v) mean(cell2mat(reshape(v,1,[])),2)
					};
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function oscs = Oscillators(parent,varargin)
			oscs	= oscs@Synth.Object(parent,[],varargin{:});
			oscs	= oscs@Group.Collection(parent,[],'Oscillator',varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
