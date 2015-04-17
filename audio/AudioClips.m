function cPathOut = AudioClips(cPathAudio,durClip,varargin)
% AudioClips
% 
% Description:	create clips from a set of audio files
% 
% Syntax:	cPathOut = AudioClips(cPathAudio,durClip,<options>)
% 
% In:
% 	cPathAudio	- the path to an audio file, or a cell of paths
%	durClip		- the duration of each clip, in seconds
%	<options>:
%		outdir:		(<base dir>) the output directory
%		outext:		(<input ext>) the output file extension
%		base:		('clip') the base output file name
%		nper:		(<max>) the maximum number of clips to save per audio file
%		nest:		(<guess>) an estimate of the total number of clips (for file
%					naming)
%		skip_start:	(0) number of seconds to skip at the beginning of the first
%					audio file
%		skip_end:	(0) number of seconds to skip at the end of the last audio
%					file
%		fade		(0) number of seconds to fade in and out at the beginning and
%					end of each clip
% 
% Out:
% 	cPathOut	- a cell of output audio clip paths
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'outdir'		, []		, ...
		'outext'		, []		, ...
		'base'			, 'clip'	, ...
		'nper'			, Inf		, ...
		'nest'			, []		, ...
		'skip_start'	, 0			, ...
		'skip_end'		, 0			, ...
		'fade'			, 0			  ...
		);

cPathAudio	= ForceCell(cPathAudio);
nAudio		= numel(cPathAudio);

if isempty(opt.nest)
%assume 5 minutes per song
	opt.nest	= max(1,round(nAudio*(300/durClip)));
end

nFill	= numel(num2str(opt.nest));

if isempty(opt.outdir)
	opt.outdir	= PathGetBase(cPathAudio);
end

cPathOut	= {};
nOut		= 0;

progress('action','init','total',nAudio,'label','Extracting clips from audio');
for kA=1:nAudio
	strExt		= unless(opt.outext,PathGetExt(cPathAudio{kA}));
	
	[x,rate]	= ReadAudio(cPathAudio{kA});
	
	if kA==1 && opt.skip_start>0
		nSkip	= t2k(opt.skip_start,rate)-1;
		x		= x(nSkip+1:end,:);
	elseif kA==nAudio && opt.skip_end>0
		nSkip	= t2k(opt.skip_end,rate)-1;
		x		= x(nSkip+1:end,:);
	end
	
	durAudio	= size(x,1)/rate;
	nPerClip	= t2k(durClip,rate)-1;
	nClip		= min(opt.nper,floor(durAudio/durClip));
	
	cPathOutCur	= arrayfun(@(k) PathUnsplit(opt.outdir,[opt.base '-' StringFill(k,nFill)],strExt),nOut+(1:nClip)','UniformOutput',false);
	
	for kC=1:nClip
		kStart	= 1 + (kC-1)*nPerClip;
		kEnd	= kStart + nPerClip - 1;
		
		xClip	= x(kStart:kEnd,:);
		
		if opt.fade>0
			fMax	= opt.fade/durClip;
			xClip	= envelope(xClip,'fmax',fMax);
		end
		
		WriteAudio(xClip,rate,cPathOutCur{kC});
	end
	
	cPathOut	= [cPathOut; cPathOutCur];
	nOut		= nOut + nClip;
	
	progress;
end
