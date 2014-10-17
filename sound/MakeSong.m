function [x,rate] = MakeSong(str,varargin)
% MakeSong
% 
% Description:	construct an audio signal from a formatted string that describes
%				a series of notes
% 
% Syntax:	[x,rate] = MakeSong(str,[durQ]=0.5,<options>)
% 
% In:
% 	str	-	 a string specifying the song, note by note.  each note follows the
%			  following syntax:
%				'[<dur>]<note>[<mod>][<octave>]', where:
%					<dur> is one of the following:
%						'w':	whole note
%						'h':	half note
%						'q':	quarter note
%						'e':	eighth note
%						's':	sixteenth note
%						't':	thirty-second notes
%						'x':	dotted whole note
%						'i':	dotted half note
%						'r':	dotted quarter note
%						'f':	dotted eighth note
%					<note> is A through G
%					<mod> is one of the following:
%						'b':	flat
%						'n':	natural
%						'#':	sharp
%					<octave> is the octave number
%			  elements in square brackets are optional and take the following
%			  default values:
%				<dur>:		'q'
%				<mod>:		'n'
%				<octave>:	<base_octave>
%			  Example:
%				ABeC#DEF#6
%	[durQ]	- the duration of a quarter note, in seconds
%	<options>:
%		rate:			(44100) the sampling rate, in Hz
%		base_octave:	(4) the base octave
%		instrument:		('sine') the instrument to use (see signalgen's 'type'
%						option)
% 
% Out:
% 	x		- an Nx1 audio signal
%	rate	- the sampling rate of the signal, in Hz
% 
% Example:
%	str = 'fCsDEeGe;rGeAGErCsDeEe;EDCiDfCsDEeGe;rGeAGErCsDeEe;EeDe;DiC;rFe;rFe;fAs;hAe;AeGe;GECiDfCsDEeGe;rGeAGErCsDeEe;EeDe;DiC;';
%	[x,rate] = MakeSong(str,0.25,'instrument','sawtooth');
% 
% Updated: 2012-11-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[durQ,opt]	= ParseArgs(varargin,0.5,...
				'rate'			, 44100		, ...
				'base_octave'	, 4			, ...
				'instrument'	, 'sine'	  ...
				);

rate	= opt.rate;

cDur	= {'w','h','q','e','s','t','x','i','r','f'};
durs	= durQ * [4 2 1 0.5 0.25 0.125 6 3 1.5 0.75];

cNote	= {'A','B','C','D','E','F','G',';'};

cMod	= {'b','n','#'};

%expand the input string
	str	= ExpandString(str);
%parse the input string
	[freq,dur]	= ParseString(str);
%construct the audio signal
	x	= ConstructSignal(freq,dur);
	
%------------------------------------------------------------------------------%
function str = ExpandString(str)
%fill in the optional parts of each note
	kStr	= 1;
	while kStr<=numel(str)
		%make sure we have a duration
			if ~ismember(str(kStr),cDur)
				str	= [str(1:kStr-1) 'q' str(kStr:end)];
			end
			
			kStr	= kStr+1;
		%make sure we have a valid note
			if ~ismember(upper(str(kStr)),cNote)
				error([str(kStr) ' is not a valid note.']);
			end
			
			str(kStr)	= upper(str(kStr));
			
			kStr	= kStr+1;
		%make sure we have a modifier
			if kStr>numel(str) || ~ismember(str(kStr),cMod)
				str	= [str(1:kStr-1) 'n' str(kStr:end)];
			end
			
			kStr	= kStr+1;
		%make sure we have an octave
			if kStr>numel(str) || str(kStr)=='i' || ~isnumstr(str(kStr))
				str	= [str(1:kStr-1) num2str(opt.base_octave) str(kStr:end)];
			end
			
			kStr	= kStr+1;
	end
end
%------------------------------------------------------------------------------%
function [freq,dur] = ParseString(str)
%convert the series of notes into arrays of frequencies and durations
	%get the frequencies
		notes	= num2cell(str(2:4:end));
		modf	= num2cell(str(3:4:end));
		octave	= num2cell(str(4:4:end));
		
		freq	= cellfun(@note2freq,notes,modf,octave);
	%get the durations
		dur			= num2cell(str(1:4:end));
		[b,kDur]	= ismember(dur,cDur);
		dur			= durs(kDur);
end
%------------------------------------------------------------------------------%
function freq = note2freq(note,modf,octave)
	octRef	= 4;
	fRef	= 440;
	
	if isequal(note,';')
		freq	= 0;
		
		return;
	end
	
	%how many semitones is the note from A?
		scale	= {'C'	'D'	'E'	'F'	'G'	'A'	'B'};
		semi	= [-9	-7	-5	-4	-2	0	2];
		
		[b,kNote]	= ismember(note,scale);
		nSemiNote	= semi(kNote);
	%how many semitones for the modifier?
		switch modf
			case 'b'
				nSemiMod	= -1;
			case 'n'
				nSemiMod	= 0;
			case '#'
				nSemiMod	= 1;
			otherwise
				error('Invalid modifier.');
		end
	%how many semitones from our octave to our reference octave?
		nSemiOct	= (str2num(octave) - octRef)*12;
		
	%calculate the frequency
		nSemiTotal	= nSemiNote + nSemiMod + nSemiOct;
		
		freq	= fRef * 2^(nSemiTotal/12);
end
%------------------------------------------------------------------------------%
function x = ConstructSignal(freq,dur)
%concatenate each frequency/duration into an audio signal
	nNote	= numel(freq);
	
	x	= [];
	
	for kN=1:nNote
		x	= [x; signalgen(freq(kN),dur(kN),'rate',opt.rate,'type',opt.instrument)];
	end
end
%------------------------------------------------------------------------------%

end
