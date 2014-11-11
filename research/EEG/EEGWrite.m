function EEGWrite(eeg,strPathEEG,varargin)
% EEGWrite
% 
% Description:	write an EEG struct to file (only supports BDF files)
% 
% Syntax:	EEGWrite(eeg,strPathEEG,<options>)
% 
% In:
% 	eeg			- an EEG struct loaded with EEGRead (doesn't support EEG files
%				  read in as windows)
%	strPathEEG	- the output file path
%	<options>:
%		silent:	(false) true to suppress status messages
% 
% Updated: 2012-02-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'silent'	, false	  ...
		);

%make sure we have good data
	if ndims(eeg.data)>2
		error('Cannot save windowed data.');
	end

status(['Writing EEG data to: ' strPathEEG],'silent',opt.silent);

%open the file for writing
	fid	= fopen(strPathEEG,'w','l');
	
	if fid==-1
		error('Could not open file for writing.');
	end
%write the header
	status('writing header information','noffset',1,'silent',opt.silent);
	
	WriteNext(eeg.hdr.id,8);			%file type identifier
	WriteNext(eeg.hdr.subject,80);		%subject description
	WriteNext(eeg.hdr.recording,80);	%recording description
	
	%recording time
		t		= FormatTime(eeg.hdr.time);
		strDate	= FormatTime(t,'dd.mm.yy');
		strTime	= FormatTime(t,'HH.MM.SS');
		
		WriteNext(strDate,8);
		WriteNext(strTime,8);
	
	WriteNext(eeg.hdr.length,8);	%bytes in header
	WriteNext(eeg.hdr.version,44);	%file version
	WriteNext(eeg.hdr.nrecord,8);	%number of records
	
	%duration of each data record
		fs	= [eeg.hdr.channel.data.rate];
		fs	= fs(1);
		
		nPerRecord	= eeg.hdr.nsample/eeg.hdr.nrecord;
		tPerRecord	= nPerRecord / fs;
		
		WriteNext(tPerRecord,8);
	%number of channels
		channel		= [eeg.hdr.channel.data; eeg.hdr.channel.status];
		nChannel	= numel(channel);
		
		WriteNext(nChannel,4);
	
	WriteNext({channel.label},16);			%channel labels
	WriteNext({channel.transducer},80);	%transducer type
	WriteNext({channel.unit},8);			%data unit
	
	%physical range
		rng		= {channel.range_physical};
		rngMin	= cellfun(@(x) x(1),rng,'UniformOutput',false);
		rngMax	= cellfun(@(x) x(2),rng,'UniformOutput',false);
		
		WriteNext(rngMin,8);
		WriteNext(rngMax,8);
	%digital range
		rng		= {channel.range_digital};
		rngMin	= cellfun(@(x) x(1),rng,'UniformOutput',false);
		rngMax	= cellfun(@(x) x(2),rng,'UniformOutput',false);
		
		WriteNext(rngMin,8);
		WriteNext(rngMax,8);
	
	WriteNext({channel.prefilter},80);	%prefiltering info
	WriteNext({channel.nsample},8)		%number of samples per record
	
	WriteNext(eeg.hdr.reserved,32*nChannel);	%some reserved thing
%write the data
	%transform the data
		status('transforming data','noffset',1,'silent',opt.silent);
		
		%convert to digital units
			%get the sets of channels that have the same mapping
				rngDigital			= cell2mat({eeg.hdr.channel.data.range_digital}');
				rngPhysical			= cell2mat({eeg.hdr.channel.data.range_physical}');
				m					= [rngDigital rngPhysical];
				[mSet,kSet,kInSet]	= unique(m,'rows');
				nSet				= numel(kSet);
			%map each set
				for kS=1:nSet
					bInSet				= kInSet==kS;
					eeg.data(bInSet,:)	= MapValue(eeg.data(bInSet,:),mSet(kS,3),mSet(kS,4),mSet(kS,1),mSet(kS,2));
				end
			
			eeg.data	= int32(round(eeg.data));
		%append the status channel.  i forget exactly what the deal is, but
		%something about the status channel being signed/unsigned screws up the
		%values
			eeg.data	= [eeg.data; int32(eeg.status) - 2.^(24-1)];
			mean(eeg.data(end,:))
		
		%reshape it to the write order
			%samples first
				eeg.data	= eeg.data';
			%separate by record
				eeg.data	= reshape(eeg.data,nPerRecord,eeg.hdr.nrecord,nChannel);
			%permute to get samples then channels then records
				eeg.data	= permute(eeg.data,[1 3 2]);
	%write the data
		status('writing data','noffset',1,'silent',opt.silent);
		
		switch eeg.hdr.datatype
			case 'int24'
				fwrite(fid,eeg.data,'bit24');
			otherwise
				fclose(fid);
				error('EEG data has unknown data type.');
		end
%close the file
	fclose(fid);


%------------------------------------------------------------------------------%
function WriteNext(x,n)
	switch class(x)
		case 'cell'
			cellfun(@(y) WriteNext(y,n),x);
		otherwise
			fwrite(fid,StringFill(x,n,' ','right'));
	end
end
%------------------------------------------------------------------------------%

end
