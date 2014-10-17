classdef SynthOscillator
% SynthOscillator
% 
% Description:	
% 
% Syntax:	synO = SynthOscillator([xSample]='sine',<options>)
%			x = synO(t,<options>)		: sample at time t
%			x = synO(t1,t2,<options>)	: sample from time t1 to t2
% 
% 			subfunctions:
%				b = save(strPathOut,t,<options>)
% 				b = save(strPathOut,[t1]=0,[t2]=<end>,<options>)
%
% 			properties:
%				sample (get/set) 
%				rate (get/set)
%				frequency (get/set)
% 
% In:
% 	xSample	- a 1D sample array, a function that takes a time, in seconds, as
%			  input and returns a sample, the path to an audio file, or one of
%			  the following presets:
%				sine
%				sawtooth
%				square
%			  if the path to an audio file is specified, options to ReadAudio
%			  may be included as well.
%	<options>:
%		rate:		(44100) the sampling rate of the sample, if a sample array
%					was specified
%		frequency:	(<determine>) the frequency of the sample
% 
% Updated: 2011-11-25
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		sample;
		rate;
		frequency;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		p_t;	%timepoint of each sample
		p_f;	%rendering function
		
		p_varargin	= {};
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function synO = set.sample(synO,x)
			opt	= ParseArgs(synO.p_varargin,...
					'rate'		, 44100	, ...
					'frequency'	, []	  ...
					);
			
			synO.frequency	= opt.frequency;
			
			if ischar(x)
				synO.sample		= lower(x);
				synO.frequency	= unless(opt.frequency,440);
				
				switch lower(x)
					case 'sine'
						synO	= synO.set('sample',@(t) sin(2*pi*t*synO.frequency));
					case 'sawtooth'
						synO	= synO.set('sample',@(t) 2*mod(t*synO.frequency,1)-1);
					case 'square'
						synO	= synO.set('sample',@(t) 2*double(mod(t*synO.frequency,1)>0.5)-1);
					otherwise
						if FileExists(x)
							[sFile,rateFile]	= ReadAudio(x,synO.p_varargin{:});
							sFile				= mean(sFile,2);
							synO				= synO.set('sample',resample(sFile,synO.rate,rateFile));
						else
							error(['"' tostring(x) '" is not a recognized sample.']);
						end
				end
			elseif isnumeric(x)
				synO.sample		= reshape(x,[],1);
				synO.p_t		= reshape(k2t(1:numel(synO.sample),synO.rate),[],1);
				
				if ~isempty(synO.sample)
					synO.p_f	= @(t) interp1(synO.p_t,synO.sample,mod(t,synO.p_t(end)+eps),'pchip');
				else
					synO.p_f	= @(t) zeros(size(t));
				end
			elseif isa(x,'function_handle')
				synO.p_f	= x;
			else
				error('Invalid sample.');
			end
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function synO = SynthOscillator(varargin)
			[xSample,opt]	= ParseArgs(varargin,'sine',...
								'rate'		, 44100	, ...
								'frequency'	, []	  ...
								);
			
			synO.p_varargin	= varargin;
			
			synO.rate		= opt.rate;
			synO.sample		= xSample;
			
			if isempty(synO.frequency)
			%determine the frequency of the sample
				synO.frequency	= 1;
				tEnd			= unless(max(synO.p_t),1);
				x				= feval(synO,0,tEnd);
				synO.frequency	= DetectPitch(x,synO.rate);
			end
			
			synO.p_varargin	= {};
		end
		function b = save(synO,strPathOut,varargin)
			[t1,t2,opt]	= ParseArgs(varargin,[],[],...
							'rate'	, synO.rate	  ...
							);
			
			%generate the sample
				x	= synO.feval(varargin{:},'interval',true);
			%save the file
				b	= WriteAudio(x,opt.rate,strPathOut);
		end
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		function [x,t] = feval(synO,varargin)
			[tStart,tEnd,opt]	= ParseArgs(varargin,0,[],...
									'interval'		, false				, ...
									'rate'			, synO.rate			, ...
									'frequency'		, synO.frequency	, ...
									'frequency_t'	, []				, ...
									'interp'		, 'pchip'			  ...
									);
			
			if isempty(tEnd) && (~opt.interval || ~isscalar(tStart))
				t	= tStart;
			else
				if isempty(tEnd)
					if isnumeric(synO.sample)
						tEnd	= k2t(numel(synO.sample)+1,synO.rate);
					else
						tEnd	= 1;
					end
				end
				
				t	= reshape(GetInterval(tStart,tEnd-1/opt.rate,1/opt.rate,'stepsize'),[],1);
			end
			
			nFrequency	= numel(opt.frequency);
			
			if nFrequency==1
			%single frequency
				x	= synO.p_f(t*opt.frequency./synO.frequency);
			else
			%frequency control points throughout signal
				if ~isempty(opt.frequency_t) || nFrequency<numel(t)
				%frequency control points
					if isempty(opt.frequency_t)
						opt.frequency_t	= GetInterval(min(t),max(t),nFrequency)';
					end
					
					if min(t)<min(opt.frequency_t)
						opt.frequency_t	= [min(t); opt.frequency_t];
						opt.frequency	= [opt.frequency(1); opt.frequency];
					end
					if max(t)>max(opt.frequency_t)
						opt.frequency_t	= [opt.frequency_t; max(t)];
						opt.frequency	= [opt.frequency; opt.frequency(end)];
					end
					
					switch lower(opt.interp)
						case 'step'
							tInterp		= interp1(opt.frequency_t,opt.frequency_t,t,'nearest');
							[b,kT]		= ismember(tInterp,opt.frequency_t);
							tDiff		= t - opt.frequency_t(kT);
							bBump		= tDiff<0;
							kT(bBump)	= min(1,kT(bBump)-1);
							
							opt.frequency	= opt.frequency(kT);
						otherwise
							opt.frequency	= interp1(opt.frequency_t,opt.frequency,t,'pchip');
					end
				end
				
				x	= fevalWarp(synO.p_f,t,opt.frequency./synO.frequency);
			end
		end
		function varargout = subsref(synO,s)
			switch s(1).type
				case '()'
					[varargout{1:nargout}]	= feval(synO,s(1).subs{:});
				case '.'
					if numel(s)>1
						[varargout{1:nargout}]	= synO.(s(1).subs)(s(2).subs{:});
					else
						[varargout{1:nargout}]	= synO.(s(1).subs);
					end
				otherwise
					error('Invalid syntax.');
			end
		end
		function synO = set(synO,strProp,x,varargin)
			synO.p_varargin	= varargin;
			
			synO.(strProp)	= x;
			
			synO.p_varargin	= {};
		end
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end