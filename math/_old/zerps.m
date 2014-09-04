function z = zerps(varargin)
% zerps
% 
% Description:	like zeros, but for zerps
% 
% Syntax:	same as zeros
% 
% Updated: 2011-03-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
sz	= size(zeros(varargin{:}));
z	= repmat({'zerp'},sz);
