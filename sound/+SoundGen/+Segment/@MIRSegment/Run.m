function Run(s,x,rate,varargin) 
% SoundGen.Segment.MIRSegment.Run
% 
% Description:	calculate segments using mirsegment
% 
% Syntax:	s.Run(x,rate,<options>)
% 
% In:
% 	x		- an Nx1 audio signal
%	rate	- the sampling rate of the audio signal, in Hz
%	<options>:
%		segment_method:		(s.method) the segmentation method
%		segment_feature:	(s.feature) the audio feature to use
%		segment_mextra:		(s.mextra) extra arguments for the segmentation
%							method
%		segment_fextra:		(s.fextra) extra arguments for the audio feature
%		reset:				(false) true to reset results calculated during
%							previous runs
% 
% Side-effects: sets s.result, an Mx2 array of segment start and end indices
% 
% Updated: 2012-11-19
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'segment_method'	, s.method	, ...
		'segment_feature'	, s.feature	, ...
		'segment_mextra'	, s.mextra	, ...
		'segment_fextra'	, s.fextra	  ...
		);

opt.segment_mextra	= ForceCell(opt.segment_mextra);
opt.segment_fextra	= ForceCell(opt.segment_fextra);

ns	= status('segmenting data (mirsegment)','silent',s.silent);

bRan	= s.ran && ~opt.reset;

if ~bRan || ~isequal(s.method,opt.segment_method) || ~isequal(s.feature,opt.segment_feature) || ~isequal(s.mextra,opt.segment_mextra) || ~isequal(s.fextra,opt.segment_fextra)
	%segment no more than 50,000,000 samples at a time
	s.result	= [];
	
	nPer	= 50000000;
	
	nX	= numel(x);
	for kS=1:nPer:nX
		kEnd	= min(kS+nPer-1,nX);
		
		xCur	= miraudio(x(kS:kEnd),rate);
		seg		= mirsegment(xCur,opt.segment_method,opt.segment_mextra{:},opt.segment_feature,opt.segment_fextra{:});
		
		frm	= get(seg,'FramePos');
		frm	= cell2mat(frm{1})';
		
		s.result	= [s.result; kS-1+t2k(frm,rate)];
	end
end
