function d = GetNextProbe(obj)
% subject.assess.base.GetNextProbe
% 
% Description:	calculate the next probe value, between 0 and 1
% 
% Syntax: d = obj.GetNextProbe()
% 
% Updated:	2015-12-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
d	= obj.d(randi(numel(obj.d)));
