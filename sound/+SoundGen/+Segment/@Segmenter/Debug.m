function dbg = Debug(s,varargin)
% SoundGen.Segment.Segmenter.Debug
% 
% Description:	return a struct of debug info about the segmentation result
% 
% Syntax:	dbg = s.Debug(<options>)
%
% In:
%	<options>:
%		segment_dur:	(<full>) the amount of the original audio for which to
%						construct debug info, in seconds
%		segment_pause:	(0.5) the duration of the pause in between segments, in
%						seconds
% 
% Updated: 2012-11-18
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dbg	= Debug@SoundGen.Operation(s,varargin{:});

opt	= ParseArgs(varargin,...
		'segment_dur'	, []	, ...
		'segment_pause'	, 0.5	  ...
		);

opt.segment_dur	= unless(opt.segment_dur,k2t(numel(s.parent.src)+1,s.parent.rate));

if s.ran
	%source sound with breaks introduced
		kMax	= t2k(opt.segment_dur,s.parent.rate)-1;
		kLast	= find(s.result(:,2)<=kMax,1,'last');
		
		nPause	= t2k(opt.segment_pause,s.parent.rate)-1;
		
		dbg.segments	= arrayfun(@(ks,ke) s.parent.src(ks:ke),s.result(1:kLast,1),s.result(1:kLast,2),'UniformOutput',false);
		
		bCol	= num2cell(isodd(1:size(s.result,1)))';
		s1		= cellfun(@(seg,b) conditional(b,seg,NaN(size(seg))),dbg.segments,bCol,'UniformOutput',false);
		s2		= cellfun(@(seg,b) conditional(~b,seg,NaN(size(seg))),dbg.segments,bCol,'UniformOutput',false);
		
		s1		= cat(1,s1{:});
		s2		= cat(1,s2{:});
		
		dbg.segments(2:end)	= cellfun(@(x) [zeros(nPause,1); x],dbg.segments(2:end),'UniformOutput',false);
		dbg.segments		= cat(1,dbg.segments{:});
	%image
		k					= round(GetInterval(1,numel(s1),10000));
		h					= alexplot({s1(k) s2(k)},'showxvalues',false,'showyvalues',false,'showgrid',false,'lax',0,'tax',0,'wax',1,'hax',1,'l',0,'t',0,'w',600,'h',200);
		dbg.image.segment	= fig2png(h.hF); 
end
