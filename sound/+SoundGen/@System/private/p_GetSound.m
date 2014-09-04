function [x,rate] = p_GetSound(sys,x)
% p_GetSound
% 
% Description:	load audio as an Nx1 array
% 
% Syntax:	[x,rate] = p_GetSound(sys,x)
% 
% In:
%	x	- the input corpus of sounds.  can be an Nx1 signal, an audio file path,
%		  the path to a directory containing audio files, or a cell of the above
% 
% Out:
% 	x		- the Nx1 audio signal
%	rate	- the sampling rate, in Hz
% 
% Updated: 2012-11-19
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
x	= ForceCell(x);
nX	= numel(x);

for kX=1:nX
	if ischar(x{kX})
		if isdir(x{kX})
			cPathAudio		= FindFilesByExtension(x{kX},{'wav','mp3'});
			[x{kX},rate]	= p_GetSound(sys,cPathAudio);
		elseif FileExists(x{kX})
			ns	= status(['loading ' x{kX}],'silent',sys.silent);
			
			%load the file
				[x{kX},rate]	= ReadAudio(x{kX});
				x{kX}			= mean(cast(x{kX},sys.type),2);
				n				= numel(x{kX});
			%delete starting and ending silence
				%silence cutoff
					thresh	= 0.1*rms(x{kX});
				%consider the first and last 10 seconds
					nSample		= min(ceil(n/2),10*rate);
				
				bNoiseStart	= abs(x{kX}(1:nSample)) >= thresh;
				bNoiseEnd	= abs(x{kX}(end-nSample+1:end)) >= thresh;
				
				kStart	= unless(find(bNoiseStart,1),1);
				kEnd	= unless(n-nSample+find(bNoiseEnd,1,'last'),n);
				
				x{kX}	= x{kX}(kStart:kEnd);
				
				durDelStart	= roundn(k2t(kStart,rate),-2);
				durDelEnd	= roundn(k2t(n-kEnd,rate),-2);
				status(['deleted first ' num2str(durDelStart) ' second' plural(durDelStart,'','s') ' and last ' num2str(durDelEnd) ' second' plural(durDelEnd,'','s')],ns+1,'silent',sys.silent);
		else
			error([x{kX} ' does not exist.']);
		end
	else
		x{kX}	= reshape(x{kX},[],1);
		rate	= 44100;
	end
end

x	= cat(1,x{:});

if isempty(x)
	error('Source corpus is empty');
end
