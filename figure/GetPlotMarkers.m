function cMarker = GetPlotMarkers(n,varargin)
% GetPlotMarkers
% 
% Description:	return a cell array of markers to use in a plot
% 
% Syntax:	cMarker = GetPlotMarkers(n,<options>)
% 
% In:
% 	n	- the number of markers to return
%	<options>:
%		markers:	(<see below>) an array of markers to choose from.  if n >
%					the number of markers in the array then any additional
%					markers are filled according to the 'fill' property
%		fill:	('random') one of the following to specify how to fill
%				additional markers:
%					'last':		use the last marker
%					'random':	use random markers
%					otherwise:	use the specified markers
% 
% Out:
% 	cMarker	- a cell of markers
% 
% Updated: 2011-02-13
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'marker'	, []		, ...
		'fill'		, 'random'	  ...
		);

cMarkerDefault	= {'o','x','*','s','^','d','.','v','>','<','p','h','+'};

if isempty(opt.marker)
	opt.marker	= cMarkerDefault;
end

opt.marker	= reshape(ForceCell(opt.marker),[],1);

%fill extra markers
	nMarker	= size(opt.marker,1);
	nFill	= n-nMarker;
	if nFill>0
		if ischar(opt.fill)
			switch opt.fill
				case 'last'
					markerFill	= repmat(opt.marker(end),[nFill 1]);
				case 'random'
					cMarkerUse	= setdiff(cMarkerDefault,opt.marker);
					
					if numel(cMarkerUse)<nFill
						cMarkerUse	= cMarkerDefault;
						bUnique		= false;
					else
						bUnique		= true;
					end
					
					markerFill	= randFrom(cMarkerUse,[nFill 1],'unique',bUnique,'repeat',false);
				otherwise
					markerFill	= repmat({opt.fill},[nFill 1]);
			end
		else
			error('The ''fill'' option must be a string.');
		end
		
		opt.marker	= [opt.marker; markerFill];
	end

%return the specified markers
	cMarker	= opt.marker(1:n);
