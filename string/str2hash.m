function h = str2hash(str,varargin)
% str2hash
% 
% Description:	convert a string to a hash value
% 
% Syntax:	h = str2hash(str,<options>)
% 
% In:
% 	str	- the string
%	<options>:
%		method:	('sdbm') the hashing method. only 'sdbm' is supported
%		output:	('number') the output type, either 'number' or 'string'. if
%				'string', the output is a hex number in string form.
%		length:	(8) the desired string length
% 
% Out:
% 	h	- the hashed value
% 
% Updated: 2015-04-15
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'method'	, 'sdbm'	, ...
		'output'	, 'number'	, ...
		'length'	, 8			  ...
		);

opt.method	= CheckInput(opt.method,'method',{'sdbm'});
opt.output	= CheckInput(opt.output,'output',{'number','string'});

nb	= 4*opt.length;
s	= uint64(str);
n	= numel(s);

switch opt.output
	case 'number'
		m	= cast(2^nb - 1,'uint64');
		c	= cast(63 + 2^(nb/2),'uint64');
		h	= 0;
		for k=1:n
			h	= mod(h*c + s(k),m);
		end
		
		h	= double(h);
	case 'string'
		if opt.length<11
			%faster to do it the number way. largest numbers we will deal with
			%above are from h*c => (2^nb * 2^(nb/2)) ~ 2^(3*(4*length)/2), means
			%length < 64*(2/12) ~ 11, since 2^64 is the largest number we can
			%deal with. 
			h	= dec2hex(str2hash(str,'length',opt.length));
		else
			m	= true(1,nb);
			c	= bitadd(int2bit(63),[false(1,nb/2) true]);
			h	= false;
			for k=1:n
				b		= int2bit(s(k));
				[q,h]	= bitdiv(bitadd(bitmult(h,c),b),m);
				%disp([s(k) bit2int(h,'uint64')])
			end
			
			h	= [h false(1,nb-numel(h))];
			h	= reshape(h,4,[])';
			h	= bit2int(h);
			h	= join(arrayfun(@dec2hex,h(end:-1:1),'uni',false),'');
		end
end
