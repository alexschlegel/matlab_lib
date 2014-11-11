function s = CreateScale(varargin)
% CreateScale
% 
% Description:	create a mapping from notes to frequencies
% 
% Syntax:	s = CreateScale([strScale]='chromatic',<options>) OR
%			s = CreateScale(cNote,f,<options>)
% 
% In:
% 	[strScale]	- one of the following strings to specify a builtin scale:
%					'chromatic': a 12-semitone octave with the following notes:
%						C(f/s) D E F G A B
%	cNote		- a cell of note names
%	f			- an array of frequencies corresponding to the notes in cNote
%	<options>:
%		octave:		(0:10) the indices of the octaves to return.  the frequencies
%					specified form the 4th octave
%		reference:	(440) the reference frequency
% 
% Out:
% 	s	- a mapping from notes to frequencies.  notes are specified either as
%		  the cNote inputs or the cNote inputs followed by a number
%		  specifying the octave (e.g. 'Cf3' for C-flat in the third octave).
% 
% Updated: 2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
cBuiltin	= {'chromatic'};

%how was the function called?
	bBuiltin	= false;
	if nargin>0
		if ischar(varargin{1})
			bBuiltin	= true;
			if ismember(varargin{1},cBuiltin)
				strScale	= varargin{1};
				varargin	= varargin(2:end);
			else
				strScale	= 'chromatic';
			end
		else
			[cNote,f]	= deal(varargin{1:2});
			varargin	= varargin(3:end);
		end
	else
		bBuiltin	= true;
		strScale	= 'chromatic';
	end
%optional arguments
	opt	= ParseArgs(varargin,...
			'octave'	, 0:10	, ...
			'reference'	, 440	  ...
			);
%get the builting scale
	if bBuiltin
		[cNote,f]	= GetBuiltinScale(strScale);
	end

%construct the mapping
	s	= mapping;
	
	if ismember(4,opt.octave)
		s{cNote{:}}	= num2cell(f);
	end
	
	for k=reshape(opt.octave,1,[])
		strK			= num2str(k);
		cNoteCur		= cellfun(@(x) [x strK],cNote,'UniformOutput',false);
		s{cNoteCur{:}}	= num2cell(2^(k-4).*f);
	end

%------------------------------------------------------------------------------%
function [cNote,f] = GetBuiltinScale(strScale)
	switch strScale
		case 'chromatic'
			cNote	= {'Cf','C','Cs','Df','D','Ds','Ef','E','Es','Ff','F','Fs','Gf','G','Gs','Af','A','As','Bf','B','Bs'};
			n		= [-1   0   1    1    2   3    3    4   5    4    5   6    6    7   8    8    9   10   10   11  12];
			f		= (opt.reference/2^(9/12))*2.^(n/12);
		otherwise
			error(['"' strScale '" is not a valid builtin scale.']);
	end
end
%------------------------------------------------------------------------------%

end