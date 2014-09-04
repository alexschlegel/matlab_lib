function Ask(sub,x,varargin)
% PTB.Subject.Ask
% 
% Description:	ask for subject info
% 
% Syntax:	sub.Ask(x,<options>)
% 
% In:
% 	x	- see the 'subject_info' option for PTB.Subject.Start
%	<options>:
%		replace:	(true) true to replace existing values.  if false and info
%					already exists, doesn't ask.
% 
% Updated: 2011-12-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
x	= ForceCell(x);

cellfun(@AskOne,x);

%------------------------------------------------------------------------------%
function AskOne(x)
	switch class(x)
		case 'cell'
			if all(cellfun(@ischar,x)) && all(ismember(x,sub.p_preset(:,1)) | ismember(x,sub.p_scheme(:,1)))
			%all presets
				cellfun(@(x) p_AskPreset(sub,x,varargin{:}),x);
			else
			%prompt specifier
				p_Ask(sub,x{:},varargin{:});
			end
		case 'char'
			p_AskPreset(sub,x,varargin{:});
		otherwise
			error('Unrecognized subject info prompt.');
	end
end
%------------------------------------------------------------------------------%

end
