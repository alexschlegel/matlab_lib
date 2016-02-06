classdef psi < subject.assess.base
% subject.assess.psi
% 
% Description:	class for assessing subject performance on a set of tasks, using
%				the "psi" adaptive procedure. see PAL_AMPM_Demo in the palamedes
%				toolbox.
% 
% Syntax: obj = subject.assess.psi(f,<options>)
%
% In:
%	f	- the value of the <f> property
%	<options>: (also see subject.assess.base)
%		marginal:	({'slope','lapse'}) the value of the <marginal> property
% 
% Methods: (also see subject.assess.base)
% 
% Properties: (also see subject.assess.base)
%	marginal:	(r) a cell of properties that are treated as marginal (i.e. of
%				secondary importance in the fitting processes). possible
%				elements are 'slope' and 'lapse'.
% 
% Updated:	2015-12-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%READ-ONLY
		properties (SetAccess=protected, GetAccess=public)
			PM;
		end
	
	%PRIVATE
		properties (SetAccess=protected, GetAccess=protected)
			
		end
%/PROPERTIES--------------------------------------------------------------------

%PROPERTY GET/SET---------------------------------------------------------------
	
%/PROPERTY GET/SET--------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = psi(f,varargin)
				obj = obj@subject.assess.base(f,varargin{:});
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			sEstimate = AppendProbe(obj,kTask,d,result);
			d = GetNextProbe(obj,s);
			y = PAL_WeibullExt(obj,params,x,varargin);
			
			function init(obj,varargin)
				%process the inputs
					opt	= ParseArgs(varargin,...
							'marginal'	, {'slope','lapse'}	  ...
							);
					
					%construct the marginal input to PAL_AMPM_setupPM
						cMarginal	= reshape(ForceCell(opt.marginal),[],1);
						cMarginal	= cellfun(@(x) CheckInput(x,'marginal',{'slope','lapse'}),cMarginal,'uni',false);
						marginal	= unique([cellfun(@(x) switch2(x,'slope',2,'lapse',4),cMarginal); 3]);
				
				%initialize the palamedes structs
					tRange		= reshape(linspace(0,1,50),[],1);
					bRange		= reshape(linspace(log10(0.0625),log10(10),50),[],1);
					lapseRange	= reshape(linspace(0,0.1,10),[],1);
					
					nTask	= numel(obj.f);
					
					warning('off','PALAMEDES:AMPM_setupPM:priorTranspose');
					obj.PM	= repmat(PAL_AMPM_setupPM(...
								'priorAlphaRange'	, tRange				, ...
								'priorBetaRange'	, bRange				, ...
								'priorGammaRange'	, obj.chance			, ...
								'priorLambdaRange'	, lapseRange			, ...
								'numTrials'			, inf					, ...
								'PF'				, @obj.PAL_WeibullExt	, ...
								'stimRange'			, obj.d					, ...
								'marginalize'		, marginal				  ...
								),[nTask 1]);
			end
		end
%/METHODS-----------------------------------------------------------------------

end
