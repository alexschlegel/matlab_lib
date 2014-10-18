classdef Oscillator < Synth.Object
% Synth.Oscillator
% 
% Description:	oscillator to generate raw signals from functions or sound
%				samples
% 
% Syntax:	osc = Synth.Oscillator(parent,strName,sample,<options>)
% 
% 			subfunctions:
%				<see Synth.Object>
%				Generate:	generate samples
%
%			properties:
%				<see Synth.Object>
%				name:		the oscillator name
%				sample:		the oscillator sample
%				rate:		the sample rate, in Hz
%				interp:		the default interpolation method for moving between
%							frequencies.  see Synth.Oscillator.Generate.
%				step_dur:	the default value for the step_dur option of
%							Synth.Oscillator.Generate
% 
% In:
%	parent		- the parent object
%	strName		- the fieldname-compatible oscillator name
%	sample		- the sample data.  one of the following:
%					x:	a 1D sample array
%					f:	the handle to a function that takes as input an array of
%						time values, in seconds, and returns a sample
%					s:	one of the following string presets:
%							'sine', 'sawtooth', 'square'
% 	<options>:
%		rate:		(44100) the sampling rate of the sample
%		interp:		('step') the initial value of the interp property
%		step_dur:	(0) the initial value of the step_dur property
% 
% Updated: 2011-12-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties (Dependent)
		name;
		sample;
		rate;
		
		interp;
		step_dur;
	end
	properties (SetAccess=protected)
		frequency;
		
		f;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		p_t;
		
		p_rate;
		p_sample;
		p_interp;
		p_step_dur;
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function strName = get.name(osc)
			strName	= osc.type;
		end
		function set.name(osc,strName)
			ifo	= osc.parent.Info.Get(osc.type);
			
			osc.parent.Info.Unset(osc.type);
			osc.parent.Info.Set(strName,ifo);
			
			osc.type	= strName;
		end
		%----------------------------------------------------------------------%
		function s = get.sample(osc)
			s	= osc.Info.Get('sample');
		end
		function set.sample(osc,s)
			if ischar(s)
				s	= CheckInput(s,'sample',{'sine','sawtooth','square'});
				
				switch lower(s)
					case 'sine'
						osc.f	= @(t) sin(2*pi*440*t);
					case 'sawtooth'
						osc.f	= @(t) 1-2*mod(440*t,1);
					case 'square'
						osc.f	= @(t) 1-2*double(mod(440*t,1)>0.5);
				end
			elseif isnumeric(x)
				s		= reshape(s,[],1);
				
				osc.p_t	= reshape(k2t(1:numel(s),osc.rate),[],1);
				
				if ~isempty(s)
					osc.f	= @(t) interp1(osc.p_t,s,mod(t,osc.p_t(end)+eps),'pchip');
				else
					osc.f	= @(t) zeros(size(t));
				end
			elseif isa(s,'function_handle')
				osc.f	= s;
			else
				error('Invalid sample.');
			end
			
			osc.frequency	= DetectPitch(osc.f(GetInterval(0,1,osc.rate)),osc.rate);
			
			osc.Info.Set('sample',s);
		end
		%----------------------------------------------------------------------%
		function r = get.rate(osc)
			r	= osc.Info.Get('rate');
		end
		function set.rate(osc,r)
			osc.Info.Set('rate',r);
		end
		%----------------------------------------------------------------------%
		function strInterp = get.interp(osc)
			strInterp	= osc.Info.Get('interp');
		end
		function set.interp(osc,strInterp)
			osc.Info.Set('interp',strInterp);
		end
		%----------------------------------------------------------------------%
		function durStep = get.step_dur(osc)
			durStep	= osc.Info.Get('step_dur');
		end
		function set.step_dur(osc,durStep)
			osc.Info.Set('step_dur',durStep);
		end
		%----------------------------------------------------------------------%
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function osc = Oscillator(parent,strName,sample,varargin)
			opt	= ParseArgs(varargin,...
								'rate'		, 44100		, ...
								'interp'	, 'step'	, ...
								'step_dur'	, 0			  ...
								);
			cOpt			= opt2cell(opt);
			
			osc	= osc@Synth.Object(parent,strName,cOpt{:});
			
			osc.p_sample	= sample;
			osc.p_rate		= opt.rate;
			osc.p_interp	= opt.interp;
			osc.p_step_dur	= opt.step_dur;
		end
		%----------------------------------------------------------------------%
		function Start(osc,varargin)
		% start the Oscillator
			osc.rate		= unless(osc.rate,osc.p_rate);
			osc.sample		= unless(osc.sample,osc.p_sample);
			osc.interp		= unless(osc.interp,osc.p_interp);
			osc.step_dur	= unless(osc.step_dur,osc.p_step_dur);
			
			Start@Group.Object(osc,varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
