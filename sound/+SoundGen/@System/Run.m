function [x,rate] = Run(sys,S,varargin)
% SoundGen.System.Run
% 
% Description:	run the sound generation process
% 
% Syntax:	[x,rate] = sys.Run(S,<options>)
% 
% In:
%	S	- the length of the cluster string to generate
% 	<options>:
%		start:		('generate') start at the latest possible step at or before
%					the specified step.  one of: 'segment', 'cluster',
%					'generate', 'exemplarize', or 'concatenate'.
%		gen_start:	(1) the index in the cluster string array at which to start
%					generation
%		<other options>:	any other options to the process subfunctions
% 
% Out:
%	x		- a Px1 array of the generated audio signal
%	rate	- the sampling rate of the signal, in Hz
% 
% Updated: 2012-11-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
tStart	= nowms;
ns		= status('sound generator begins!','silent',sys.silent);

opt	= ParseArgs(varargin,...
		'start'		, 'generate'	, ...
		'gen_start'	, 1				  ...
		);

cStep	=	{
				'segment'
				'cluster'
				'generate'
				'exemplarize'
				'concatenate'
			};
bStatus	=	[
				sys.segmented
				sys.clustered
				sys.generated
				sys.exemplarized
				sys.concatenated
			];
nStep	= numel(cStep);

%get the first step to perform
	opt.start	= CheckInput(opt.start,'start',cStep);
	
	kStepWant	= FindCell(cStep,opt.start);
	kStepStart	= unless(find(~bStatus(1:kStepWant),1,'first'),kStepWant);
%make sure we got everything we need
	if kStepStart<=FindCell(cStep,'generate') && nargin<2
		error('You must specify a cluster string length.');
	end
%perform each step
	for kS=1:kStepStart-1
		status(['already performed ' cStep{kS} ' step'],ns+2,'silent',sys.silent);
	end
	
	for kS=kStepStart:nStep
		switch cStep{kS}
			case 'segment'
				sys.Segment(varargin{:});
			case 'cluster'
				sys.Cluster(varargin{:});
			case 'generate'
				sys.Generate(opt.gen_start,S,varargin{:});
			case 'exemplarize'
				sys.Exemplarize(opt.gen_start,varargin{:});
			case 'concatenate'
				sys.Concatenate(varargin{:});
		end
	end


x		= sys.result;
rate	= sys.rate;

ns	= status(['sound generator finished! (' FormatTime(nowms-tStart,'H:MM:SS.FFF') ')'],'silent',sys.silent);
