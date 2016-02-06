classdef stairstep < subject.assess.base
% subject.assess.stairstep
% 
% Description:	class for assessing subject performance on a set of tasks, using
%				a stair stepping procedure. difficulty increases as subjects
%				respond correctly and decreases as they respond incorrectly.
% 
% Syntax: obj = subject.assess.stairstep(f,<options>)
%
% In:
%	f	- the value of the <f> property
%	<options>: (also see subject.assess.base)
%		acceleration:	(0.01) the value of the <acceleration> property
%		stickiness:		(1) the value of the <stickiness> property
%		maxweight:		(3) the value of the <maxweight> property
% 
% Methods: (also see subject.assess.base)
% 
% Properties: (also see subject.assess.base)
%	acceleration:	(r) the amount by which the step size changes with each
%		consecutive size increase or decrease. must be positive.
%	stickiness:	(r) the number of consistent responses needed before the step
%		size changes. must be a positive integer.
%	maxweight: (r) make sure that no point gets more than <maxweight> times the
%				number of probes it would get in a uniform probing of the space
% 
% Updated:	2015-12-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%READ-ONLY
		properties (SetAccess=protected, GetAccess=public)
			acceleration	= NaN;
			stickiness		= NaN;
			maxweight		= NaN;
		end
	
	%PRIVATE
		properties (SetAccess=protected, GetAccess=protected)
			position			= [];
			speed				= [];
			stickinessCounter	= [];
		end
%/PROPERTIES--------------------------------------------------------------------

%PROPERTY GET/SET---------------------------------------------------------------
	
%/PROPERTY GET/SET--------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = stairstep(f,varargin)
				obj = obj@subject.assess.base(f,varargin{:});
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			d = GetNextProbe(obj,s);
			
			function init(obj,varargin)
				opt	= ParseArgs(varargin,...
						'acceleration'	, 0.01	, ...
						'stickiness'	, 1		, ...
						'maxweight'		, 3		  ...
						);
				
				assert(isscalar(opt.acceleration) && opt.acceleration>0,'acceleration must be a positive scalar');
				assert(isscalar(opt.stickiness) && opt.stickiness>0 && isint(opt.stickiness),'stickiness must be a positive integer');
				
				obj.acceleration	= opt.acceleration;
				obj.stickiness		= opt.stickiness;
				obj.maxweight		= opt.maxweight;
				
				nTask					= numel(obj.f);
				obj.position			= repmat(obj.ability,[nTask 1]);
				obj.speed				= zeros(nTask,1);
				obj.stickinessCounter	= zeros(nTask,1);
			end
		end
%/METHODS-----------------------------------------------------------------------

end
