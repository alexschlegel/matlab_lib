function chr = key2char(key,k,varargin)
% PTB.Device.Input.Keyboard.key2char
% 
% Description:	get the ASCII character of a key given its state index
% 
% Syntax:	chr = key.key2char(k,[bShift]=false)
% 
% In:
%	k			- the state index
%	[bShift]	- true to return the character with the Shift key down
% 
% Out:
%	chr	- the ASCII character, or NaN if the key has none
%
% Updated: 2011-12-24
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent k2c k2cShift;

if isempty(k2c)
	cMap	=	{
					'1'				'1'	'!'
					'2'				'2'	'@'
					'3'				'3'	'#'
					'4'				'4'	'$'
					'5'				'5'	'%'
					'6'				'6'	'^'
					'7'				'7'	'&'
					'8'				'8'	'*'
					'9'				'9'	'('
					'0'				'0'	')'
					'minus'			'-'	'_'
					'equal'			'='	'+'
					'backspace'		8	8
					'tab'			9	9
					'q'				'q'	'Q'
					'w'				'w'	'W'
					'e'				'e'	'E'
					'r'				'r'	'R'
					't'				't'	'T'
					'y'				'y'	'Y'
					'u'				'u'	'U'
					'i'				'i'	'I'
					'o'				'o'	'O'
					'p'				'p'	'P'
					'bracketleft'	'['	'{'
					'bracketright'	']'	'}'
					'return'		10	10
					'a'				'a'	'A'
					's'				's'	'S'
					'd'				'd'	'D'
					'f'				'f'	'F'
					'g'				'g'	'G'
					'h'				'h'	'H'
					'j'				'j'	'J'
					'k'				'k'	'K'
					'l'				'l'	'L'
					'semicolon'		';'	':'
					'apostrophe'	''''	'"'
					'grave'			'`'	'~'
					'backslash'		'\'	'|'
					'z'				'z'	'Z'
					'x'				'x'	'X'
					'c'				'c'	'C'
					'v'				'v'	'V'
					'b'				'b'	'B'
					'n'				'n'	'N'
					'm'				'm'	'M'
					'comma'			','	'<'
					'period'		'.'	'>'
					'slash'			'/'	'?'
					'kp_multiply'	'*'	'*'
					'space'			' '	' '
					'kp_subtract'	'-'	'-'
					'kp_add'		'+'	'+'
					'kp_divide'		'/'	'/'
					'kp_equal'		'='	'='
				};
	
	k2c			= mapping(cMap(:,1),cMap(:,2));
	k2cShift	= mapping(cMap(:,1),cMap(:,3));
end

bShift	= ParseArgs(varargin,false);

strName	= lower(KbName(k));

if bShift
	chr	= k2cShift(strName);
else
	chr	= k2c(strName);
end

if isempty(chr)
	chr	= NaN;
end
