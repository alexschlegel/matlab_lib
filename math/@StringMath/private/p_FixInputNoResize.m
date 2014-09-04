function varargout = p_FixInputNoResize(varargin)
% p_FixInputNoResize
% 
% Description:	make the inputs all StringMath objects
% 
% Syntax:	[x1,...,xN,bEmptyInput] = p_FixInputNoResize(x1,...,xN)
% 
% In:
% 	xK	- the Kth input
% 
% Out:
% 	xK			- the Kth input as a StringMath object
%	bEmptyInput	- true if any of the inputs were empty
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%index of the first StringMath object
	kSM	= 0;

%make StringMath
	bEmptyInput	= false;
	varargout	= [varargin {false}];
	for k=1:nargin
		if ~isempty(varargin{k})
			if ~isa(varargin{k},'StringMath')
				%get the index of the first StringMath object
					if kSM==0
						kSM	= find(cellfun('isclass',varargin,'StringMath'),1,'first');
					end
				
				varargout{k}	= p_TransferProperties(varargin{kSM},StringMath(varargin{k}));
			end
		else
			bEmptyInput	= true;
		end
	end
	varargout{nargin+1}	= bEmptyInput;
	