function x = FormatTime(y,varargin)
% FormatTime
% 
% Description:	format a date/time number as a string or string as a number
% 
% Syntax:	str = FormatTime(t,[f]=31) OR
%			t = FormatTime(str,[f])
% 
% In:
% 	t	- number of milliseconds since the epoch, or a string representing a
%		  time
%	str	- a string representing a time
%	[f]	- format as in calls to datestr, with the following exceptions:
%			'informal_day'	- return an informal rendering of the day, either
%							  "yesterday", "today", "tomorrow", "dddd the ddth",
%							  or "dddd mm/dd"
%			'dddd the ddth'	- return "<day of the week> the <date><th/st/etc.>"
%			'H:MM:SS[.FFF]'	- collapse everything at the day level and
%							  greater to number of hours
%			'S[.FFF]'		- collapse everything at the minute level and
%							  greater to number of seconds
%		  for conversion of string to ms, f is required if the string isn't in
%		  one of the formats automatically recognized by datenum.
% 
% Out: (see inputs)
% 
% Updated:	2014-08-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if ischar(y)
	y	= lower(y);
	
	bEnd	= numel(y)>7 && isequal(y(1:7),'end of ');
	bStart	= numel(y)>9 && isequal(y(1:9),'start of ');
	
	if bEnd
		y	= y(8:end);
	end
	if bStart
		y	= y(10:end);
	end
	
	switch y
		case 'yesterday'
			x	= FormatTime(FormatTime(nowms,'yyyy-mm-dd'))-86400000;
		case 'today'
			x	= FormatTime(FormatTime(nowms,'yyyy-mm-dd'));
		case 'tomorrow'
			x	= FormatTime(FormatTime(nowms,'yyyy-mm-dd'))+86400000;
		otherwise
			if numel(varargin)>0
				x	= String2Date(y);
			else
				sAgo	= regexp(y,'(?<time>\d+) (?<unit>.*[^s])[s]? ago','names');
				
				if ~isempty(sAgo)
					tNow	= nowms;
					tRel	= str2num(sAgo.time);
					strUnit	= lower(sAgo.unit);
					
					cSpecial	=	{
										'moment'	'second'	90
										'week'		'day'		7
										'fortnight'	'day'		14
										'quarter'	'month'		3
										'season'	'month'		3
										'decade'	'year'		10
										'jubilee'	'year'		50
										'century'	'year'		100
										'centurie'	'year'		100
										'millenium'	'year'		1000
										'millenia'	'year'		1000
									};
					
					[bSpecial,kSpecial]	= ismember(strUnit,cSpecial(:,1));
					if bSpecial
						strUnit	= cSpecial{kSpecial,2};
						tRel	= cSpecial{kSpecial,3}*tRel;
					end
					
					tSerial	= ms2serial(tNow);
					x		= addtodate(tSerial, -tRel, strUnit);
					x		= serial2ms(x);
				else
					x	= String2Date(y);
				end
			end
	end
	
	if bEnd
		x	= StartOfDay(x)+86400000-1;
	elseif bStart
		x	= StartOfDay(x);
	end
else
	f	= ParseArgs(varargin,31);
	
	%convert t to a date number
		y	= y / 86400000;
		
	%format as specified
		regHour		= '^H:MM:SS(\.FFF)?$';
		regSecond	= '^S(\.FFF)?$';
		regMS		= '\.FFF';
		
		if ischar(f) && ~isempty(regexp(f,regHour))
			if isnan(y)
				x	= '??:??:??';
			elseif isinf(y)
				x	= 'Inf';
			else
				%get the sub-hour portion
					strSubHour	= datestr(y,f(3:end));
					
				%get the number of hours
					nHour		= floor(y*24);
					
				%construct the string
					x	= [num2str(nHour) ':' strSubHour];
			end
		elseif ischar(f) && ~isempty(regexp(f,regSecond))
			if isnan(t)
				x	= '??';
			elseif isinf(t)
				x	= 'Inf';
			else
				%get the sub-second portion
					if regexp(f,regMS)
						strSubSecond	= datestr(y,'.FFF');
					else
						strSubSecond	= '';
					end
					
				%get the number of seconds
					nSecond	= floor(y*86400);
				
				%construct the string
					x	= [num2str(nSecond) strSubSecond];
			end
		elseif isequal(lower(f),'dddd the ddth')
			strDDDD	= datestr(y,'dddd');
			strDD	= datestr(y,'dd');
			if isequal(strDD(1),'0')
				strDD	= strDD(2);
			end
			strOrdinal	= GetOrdinal(str2num(strDD));
			
			x	= [strDDDD ' the ' strDD strOrdinal];
		elseif isequal(lower(f),'informal')
			yMS	= y * 86400000;
		
			x	= [FormatTime(yMS,'informal_day') ' at ' lower(FormatTime(yMS,'HH:MMPM'))];
		elseif isequal(lower(f),'informal_day')
			yMS	= y * 86400000;
			
			if IsYesterday(yMS)
				x	= 'yesterday';
			elseif IsToday(yMS)
				x	= 'today';
			elseif IsTomorrow(yMS)
				x	= 'tomorrow';
			elseif IsThisMonth(yMS)
				x	= FormatTime(yMS,'dddd the ddth');
			else
				strDDDD	= datestr(y,'dddd');
				strMM	= datestr(y,'mm');
				if isequal(strMM(1),'0')
					strMM	= strMM(2);
				end
				strDD	= datestr(y,'dd');
				if isequal(strDD(1),'0')
					strDD	= strDD(2);
				end
				
				x	= [strDDDD ', ' strMM '/' strDD];
			end
		else
			bNaN	= isnan(y);
			if bNaN
				y	= 0;
			end
			
			x	= datestr(y,f);
			
			if bNaN
				x	= regexprep(x,'\w','?');
			end
		end
end

%------------------------------------------------------------------------------%
function t = String2Date(str)
	%first test whether we have a weird YYYY:MM:DD date
		str	= regexprep(str,'(\d{4}):(\d{2}):(\d{2})','$1-$2-$3');
	
	try
		t	= datenum(str,varargin{:})*86400000;
	catch
		cREOdd	= {
			'([0-2]\d{3})([01]\d)([0-3]\d)([01]\d)([0-5]\d)([0-5]\d)$'	'$1-$2-$3 $4:$5:$6'	%YYYYMMDDHHMMSS
			'^([0-2]\d{3})([01]\d)([0-3]\d)$'							'$1-$2-$3'			%YYYYMMDD
		};
		nREOdd	= size(cREOdd,1);
		
		for kRE=1:nREOdd
			strNew	= regexprep(str,cREOdd{kRE,:});
			if ~strcmp(str,strNew)
				t	= String2Date(strNew);
				if ~isnan(t)
					return;
				end
			end
		end
		
		t	= NaN;
	end
end
%------------------------------------------------------------------------------%

end
