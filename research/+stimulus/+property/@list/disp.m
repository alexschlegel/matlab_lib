function disp(obj)
% stimulus.property.list.disp
% 
% Description:	display the property choice list
% 
% Syntax: disp(obj)
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
disp(sprintf('(%s list) [%s]',join(obj.size,'x'),join(obj.values,',')));
