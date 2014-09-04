classdef Sample < handle
% Sound.Sample
% 
% Description:	a sound sample, can be derived from a sound file, signal array,
%				or generating function
% 
% Syntax:	smp = Sound.Sample(src,[rate]=<auto>,<options>)
% 
% 			subfunctions:
%				Play	- play the sample
%				Data	- retrieve sample data
%				Step	- retrieve sample data, stepping from the previously
%						  retrieved data
% 			 
% 			properties:
%				src			- an Nx1 array of the source sound
%				rate		- the sampling rate, in Hz
%				duration	- the sample duration, in seconds
% 
% In:
%	src		- the sound data. either:
%				- the path to a sound file
%				- an Nx1 audio signal
%				- the handle to a function that takes a time array, in seconds,
%				  and a rate, in Hz,  and returns the data samples for the given
%				  times 
%	[rate]	- the sampling rate, in Hz
%	<options>:
%		duration:	(1) the sample duration. only applies for function source
%					data.
%
% Updated: 2014-07-29
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	%CONSTANT PROPERTIES-------------------------------------------------------%
	properties (GetAccess=protected, Constant=true)
		DEFAULT_RATE	= 44100;
	end
	%CONSTANT PROPERTIES-------------------------------------------------------%
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		src			= [];
		src_data	= [];
		rate		= 0;
	end
	properties (SetAccess=protected)
		duration	= 0;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		default_duration	= 1;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function smp = set.src(smp,src)
			bFunctionize	= true;
			switch class(src)
				case 'char'
					[smp.src_data,smp.rate]	= ReadAudio(src);
					smp.src_data			= mean(smp.src_data,2);
				case 'function_handle'
					smp.src_data	= src;
					smp.rate		= smp.DEFAULT_RATE;
					bFunctionize	= false;
				case 'Sound.Sample'
					smp.src_data	= src.src_data;
					smp.rate		= src.rate;
				otherwise
					if isnumeric(src)
						smp.src_data	= reshape(src,[],1);
						smp.rate		= smp.DEFAULT_RATE;
					else
						error('Invalid source type.');
					end
			end
			
			if bFunctionize
				smp.duration	= numel(smp.src_data)/smp.rate;
				smp.src			= @(t,r) smp.src_data(min(numel(smp.src_data),max(0,round(mod(t*r-1,numel(smp.src_data))+1))));
			else
				smp.duration	= smp.default_duration;
				smp.src			= smp.src_data;
			end
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function smp = Sample(src,varargin)
			[rate,opt]	= ParseArgs(varargin,[],...
							'duration'	, smp.default_duration	  ...
							);
			
			smp.src					= src;
			smp.default_duration	= opt.duration;
			
			if ~isempty(rate)
				smp.rate	= rate;
			end
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
	methods (Access=private)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
