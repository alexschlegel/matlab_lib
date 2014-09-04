classdef Synth < Group
% Synth
% 
% Description:	music synthesizer
% 
% Syntax:	syn = Synth(<options>)
%
% 			subclasses:
%				<see Group>
%				Oscillator:	a collection of Synth.Oscillators
%
% 			methods:
%				<see Group>
%
%			properties:
%				<see Group>
%
% In:
%	<options>:
% 
% Updated: 2011-12-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function syn = Synth(varargin)
			syn	= syn@Group('synth',...
					'attach_class'	, {'Info','File','Scheduler','Status','Prompt','Log','Oscillators'}	  ...
					);
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
