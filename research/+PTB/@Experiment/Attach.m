function Attach(ptb,varargin)
% PTB.Attach
% 
% Description:	attach a PTB.Object to the experiment
% 
% Syntax:	ptb.Attach(strName,obj) OR
%			ptb.Attach(sObj)
% 
% In:
%	strName	- the name of the object.  must not conflict with existing objects
%	obj		- the PTB.Object
%	sObj	- a struct of objects named according to their field names
%
% Side-effects:	Start()s the object after attaching it and End()s the object at
%				the end of the experiment
% 
% Updated: 2012-02-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

if numel(varargin)>1
%attach a single object
	[strName,obj]	= deal(varargin{1:2});
	
	%add the property to our list of dynamic objects
		ptb.Info.Set('experiment',{'object',strName},obj);
	%add the property
		addprop(ptb,strName);
		ptb.(strName)	= obj;
	%set the parent
		ptb.(strName).SetParent(ptb);
	%start it
		ptb.(strName).Start(ptb.argin{:});
else
%attach a struct of objects
	sObj	= varargin{1};
	
	if ~isempty(sObj) && ~isequal(sObj,struct)
		cField	= fieldnames(sObj);
		nField	= numel(cField);
		
		%attach the objects
			for kF=1:nField
				addprop(ptb,cField{kF});
				ptb.(cField{kF})	= sObj.(cField{kF});
			end
		%set the parents
			for kF=1:nField
				ptb.(cField{kF}).SetParent(ptb);
			end
		%start them
			for kF=1:nField
				ptb.(cField{kF}).Start(ptb.argin{:});
			end
	end
end
