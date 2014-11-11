function s = birthEstimator(dueDate,varargin)
% birthEstimator
% 
% Description:	estimate some statistics about birth date, given due date
% 
% Syntax:	s = birthEstimator(dueDate,<options>)
% 
% In:
% 	dueDate	- the due date, either as a nowms time or a string
%	<options>:
%		reference_date:		(<due date>) the reference date
%		now:				(<nowms>) the "now" date
%		previous_births:	(0) the number of previous births 
% 
% Out:
% 	s	- a struct of info estimating the birth date
%
% Notes:
%	data from http://spacefem.com/pregnant/charts/duedate6.php
% 
% Updated: 2014-09-29
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent sData

%load the birth data
	if isempty(sData)
		strPathData	= PathAddSuffix(mfilename('fullpath'),[],'dat');
		sData		= table2struct(fget(strPathData));
	end

%parse the inputs
	opt	= ParseArgs(varargin,...
			'reference_date'	, []	, ...
			'now'				, nowms	, ...
			'previous_births'	, 0		  ...
			);
	
	if isa(dueDate,'char')
		dueDate	= FormatTime(dueDate);
	end
	
	opt.reference_date	= unless(opt.reference_date,dueDate);
	if isa(opt.reference_date,'char')
		opt.reference_date	= FormatTime(opt.reference_date);
	end
	
	if isa(opt.now,'char')
		opt.now	= FormatTime(opt.now);
	end
	
	tConception		= dueDate - ConvertUnit(40,'week','ms');
	
	day				= sData.day;
	pBirthByDay		= sData.(['prc' num2str(opt.previous_births)])/100;
	pBirthByDay		= pBirthByDay/sum(pBirthByDay);
	pBirthByDay		= pBirthByDay/sum(pBirthByDay);
	pBirthOnDay		= fit(day,pBirthByDay,'cubicinterp');

%dates as days
	dayNow			= ConvertUnit(opt.now - tConception,'ms','day');
	dayReference	= ConvertUnit(opt.reference_date - tConception,'ms','day');

%stats!
	precision	= 0.01;
	
	kDayNow	= find(abs(dayNow-day)==min(abs(dayNow-day)));
	kDayRef	= find(abs(dayReference-day)==min(abs(dayReference-day)));
	
	%probability of birth today
		s.pBirthToday		= pBirthOnDay(dayNow);
	%probability of birth today, given no birth yet
		dayAll		= day(kDayNow):precision:day(end);
		dayTest		= day(kDayNow):precision:(day(kDayNow+1)-precision);
		cumPAll		= sum(pBirthOnDay(dayAll));
		cumPTest	= sum(pBirthOnDay(dayTest));
		
		s.pBirthTodayGivenNoBirth	= cumPTest/cumPAll;
	%probability of birth on the reference day
		s.pBirthOnReference	= pBirthOnDay(dayReference);
	%probability of birth on reference day, given no birth yet
		dayAll		= day(kDayRef):precision:day(end);
		dayTest		= day(kDayRef):precision:(day(kDayRef+1)-precision);
		cumPAll		= sum(pBirthOnDay(dayAll));
		cumPTest	= sum(pBirthOnDay(dayTest));
		
		s.pBirthOnReferenceGivenNoBirth	= cumPTest/cumPAll;
	%probability of birth between now and reference day
		dayAll		= day(1):precision:day(end);
		dayTest		= dayNow:precision:dayReference;
		cumPAll		= sum(pBirthOnDay(dayAll));
		cumPTest	= sum(pBirthOnDay(dayTest));
		
		s.pBirthNowToReference	= cumPTest/cumPAll;
	%probability of birth between now and date, given no birth yet
		dayAll		= day(kDayNow):precision:day(end);
		cumPAll		= sum(pBirthOnDay(dayAll));
		dayTest		= dayNow:precision:dayReference;
		cumPTest	= sum(pBirthOnDay(dayTest));
		
		s.pBirthNowToReferenceGivenNoBirth	= cumPTest/cumPAll;
	
	