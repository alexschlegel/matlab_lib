function Set(sub,strName,x,varargin)
% PTB.Subject.Set
% 
% Description:	store a piece of subject info
% 
% Syntax:	sub.Set(strName,x,<options>)
%
% In:
%	strName	- the name of the info, must be field name compatible
%	x		- the value of the info
%	<options>: (see PTB.Info.Set)
% 
% Updated: 2012-02-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bInit	= isequal(strName,'init');

if bInit
	x	= lower(x);
end

sub.parent.Info.Set('subject',strName,x,varargin{:});

if bInit
	strCode	= p_GetCode(sub);
	
	bLoaded	= sub.parent.Info.SetName(strCode);
	strCode	= sub.parent.Info.Get('session','name');
	
	sub.parent.File.Set('subject','data',[sub.parent.Info.Get('subject','init') '.mat']);
	
	%check for existing info
		bLoad	= sub.parent.Info.Get('subject','load');
		if ~bLoaded && notfalse(bLoad) && isequal(strName,'init')
			if sub.parent.File.Exists('subject')
				if isequal(bLoad,true)
					res	= 'y';
				else
					res	= sub.parent.Prompt.Ask(['Subject "' x '" exists.  Load existing subject info?'],'choice',{'y','n','abort'});
				end
				
				switch res
					case 'y'
						sub.Load;
					case 'abort'
						error('User aborted.');
				end
			end
		end
	
	sub.Set('code',strCode,varargin{:});
end
