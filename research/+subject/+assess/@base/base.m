classdef base < handle
% subject.assess.base
% 
% Description:	base class for assessing subject performance on a task whose
%				difficulty ranges from 0 to 1
% 
% Syntax: obj = subject.assess.base(f,<options>)
%
% In:
%	f	- the value of the <f> property
%	<options>:
%		target:		(0.75) the value of the <target> property
%		chance:		(0.5) the value of the <chance> property
%		estimate:	(0.5) an initial estimate of the subject's ability
%		d:			(0:0.05:1) the value of the <d> property
% 
% Methods:
%	Step:	run one step of the assessment
%	Run:	run a full assessment
% 
% Properties:
%	f:	(r) a function that takes a difficulty value between 0 and 1, 0 being
%		the easiest, as an input, presents the subject with a task at the
%		specified difficulty, and returns true if the subject was correct, or
%		false otherwise. see also the SimulateProbe class method
%	d:	(r) allowed values of d
%	target:	(r) the target subject performance, as fraction of tasks correct
%	chance:	(r) the chance level of subject performance
%	ability:	(r) the current estimate of the difficulty value at which the
%		subject will perform according to the target
%	steepness:	(r) the current estimate of the steepness of the subject's
%		psychometric curve
%	rmse:	(r) the root mean square error between the fit and the data
%	r2:	(r) the degree of freedom adjusted r^2 between the fit and the data
%	history:	(r) a struct recording the performance history and ability
%		estimates
% 
% Updated:	2015-12-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%READ-ONLY
		properties (SetAccess=protected, GetAccess=public)
			f			= [];
			d			= [];
			target		= NaN;
			chance		= NaN;
			ability		= NaN;
			steepness	= 5;
			rmse		= NaN;
			r2			= NaN;
			history		= struct;
		end
	
	%PRIVATE
		properties (SetAccess=protected, GetAccess=protected)
			
		end
%/PROPERTIES--------------------------------------------------------------------

%PROPERTY GET/SET---------------------------------------------------------------
	methods
		function x = get.target(obj)
			x	= obj.target;
		end
		function obj = set.target(obj,x)
			obj.target	= x;
		end
	end
%/PROPERTY GET/SET--------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = base(f,varargin)
				obj = obj@handle();
				
				opt	= ParseArgs(varargin,...
						'target'	, 0.75		, ...
						'chance'	, 0.5		, ...
						'estimate'	, 0.5 		, ...
						'd'			, 0:0.05:1	  ...
						);
				
				obj.f		= f;
				obj.d		= sort(reshape(opt.d,[],1));
				obj.target	= opt.target;
				obj.chance	= opt.chance;
				obj.ability	= opt.estimate;
				
				obj.history			= dealstruct('d','f','n',[]);
				obj.history.record	= repmat(dealstruct('d','result','ability','steepness','rmse','r2',[]),[0 0]);
			end
		end
	
	%STATIC
		methods (Access=public, Static)
			b = SimulateProbe(d,varargin)
		end
	
	%PRIVATE
		methods (Access=protected)
			d = GetNextProbe(obj);
			AppendProbe(obj,d,b);
			[a,s,rmse,r2] = EstimateAbility(obj,d,f,n);
			[dFit,fFit,nFit] = GetFitValues(obj,d,b)
		end
%/METHODS-----------------------------------------------------------------------

end
