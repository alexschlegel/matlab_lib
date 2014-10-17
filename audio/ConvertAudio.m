function bSuccess = ConvertAudio(strPathIn,strPathOut,varargin)
% ConvertAudio
% 
% Description:	convert audio from one format to another (requires avconv, or
%				lame for mp3 input/output)
% 
% Syntax:	bSuccess = ConvertAudio(strPathIn,strPathOut,<options>)
% 
% In:
% 	strPathIn	- the path to the file to convert
%	strPathOut	- the output path
%	<options>:
%		lame:	(false) true to use lame for mp3 files
%		rate:	(<input rate>) output data rate, in kbps
%		start:	(<beginning>) the start of the period to convert, in seconds
%		end:	(<end>) the end of the period to convert, in seconds
%		silent:	(false) true to suppress status messages
%
% Out:
%	bSuccess	- true if avconv didn't return an error code
% 
% Updated:	2014-07-29
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	=	ParseArgs(varargin,...
			'lame'		, false	, ...
			'rate'		, []	, ...
			'start'		, 0		, ...
			'end'		, []	, ...
			'silent'	, false	  ...
			);

bSuccess	= true;
bSlice		= opt.start~=0 || ~isempty(opt.end);

cPathIntermediate	= {};

%input and output types
	strExtIn	= lower(PathGetExt(strPathIn));
	strExtOut	= lower(PathGetExt(strPathOut));

% %possibly convert to wav first
	bToWave		= opt.lame && (isequal(strExtIn,'mp3') || isequal(strExtOut,'mp3'));
	
	if bToWave
		cPathIntermediate{end+1}	= GetTempFile('ext','wav');
		
		bDoSlice	= false;
		switch strExtIn
			case 'mp3'
				bDoSlice	= true;
				fConvert	= @ConvertAudio_lame;
			otherwise
				fConvert	= @ConvertAudio_avconv;
		end
		
		bSuccess	= fConvert(strPathIn,cPathIntermediate{end});
		strPathIn	= cPathIntermediate{end};
		
		if bSuccess && bDoSlice
			cPathIntermediate{end+1}	= GetTempFile('ext','wav');
			bSuccess					= ConvertAudio_avconv(strPathIn,cPathIntermediate{end});
			strPathIn					= cPathIntermediate{end};
		end
	end
if bSuccess
%convert to the final file
	switch lower(PathGetExt(strPathOut))
		case 'mp3'
			fConvert	= conditional(opt.lame,@ConvertAudio_lame,@ConvertAudio_avconv);
		case 'wav'
			bCopy		= isequal(strExtIn,'wav') && ~bSlice;
			fConvert	= conditional(bCopy,@(fi,fo) FileCopy(fi,fo,'createpath',true),@ConvertAudio_avconv);
		otherwise
			fConvert	= @ConvertAudio_avconv;
	end
	
	bSuccess	= fConvert(strPathIn,strPathOut);
end
%delete the intermediate files
	bDelete	= FileExists(cPathIntermediate);
	cellfun(@delete,cPathIntermediate(bDelete));

%------------------------------------------------------------------------------%
function b = ConvertAudio_lame(strPathIn,strPathOut)
	strOpt	= conditional(~isempty(opt.rate),['-b ' num2str(opt.rate)],'');
	
	strCommand	= ['lame ' strOpt ' "' strPathIn '" "' strPathOut '"'];
	[ec,strOut]	= RunBashScript(strCommand,'silent',opt.silent);
	b			= ec==0;
end
%------------------------------------------------------------------------------%
function b = ConvertAudio_avconv(strPathIn,strPathOut)
	strOptRate	= conditional(~isempty(opt.rate),[' -ab ' num2str(opt.rate) 'k'],'');
	strOptStart	= conditional(bSlice && opt.start~=0,[' -ss ' num2str(opt.start)],'');
	strOptEnd	= conditional(bSlice && ~isempty(opt.end),[' -t ' num2str(opt.end - opt.start)],'');
	
	strOptIn	= [strOptStart strOptEnd];
	strOptOut	= [strOptRate];
	
	strCommand	= ['avconv -y ' strOptIn ' -i "' strPathIn '" ' strOptOut ' "' strPathOut '"'];
	[ec,strOut]	= RunBashScript(strCommand,'silent',opt.silent);
	b			= ec==0;
	
	%we only need to slice once
		bSlice	= false;
end
%------------------------------------------------------------------------------%

end
