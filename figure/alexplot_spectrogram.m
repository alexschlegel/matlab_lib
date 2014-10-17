function h = alexplot_spectrogram(x,h,vargin)
% alexplot_spectrogram
% 
% Description:	plot the spectrogram of a signal
% 
% Syntax:	h = alexplot(t,f,p,'type','spectrogram',<options>)
% 
% In:
%	t	- an nSample x 1 array of time points for each psd value
%	f	- an nFreq x 1 array of frequencies for each psd value
%	p	- an nFreq x nSample array of the power estimations (in dB) of the
%		  signal at each frequency and time point
% 	<spectrogram-specific options>:
%		substyle:	('color') a string to specify the following default options:
%						'color':
%							lut:		(<DB B Y R M>)
%						'bw':
%							lut:		(<B W>)
%		lut:		(<see subtype>) an Nx3 LUT for the spectrogram
%		pmin:		(<auto>) the minimum of the p display range
%		pmax:		(<auto>) the maximum of the p display range
%		ylog:		(false) true to log scale the frequency axis
%		sig:		(<don't show>) an nFreq x nSample logical array indicating
%					which psd values are significant.  saturation of
%					non-significant values is decreased.
% 
% Updated: 2011-04-26
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%parse the extra options
	strStyle	= getfield(ParseArgs(vargin,'substyle','color'),'substyle');
	optD		= GetStyleDefaults(strStyle);
	h.opt		= StructMerge(h.opt,ParseArgs(vargin,...
					'substyle'		, 'color'	, ...
					'lut'			, optD.lut	, ...
					'pmin'			, []		, ...
					'pmax'			, []		, ...
					'ylog'			, false		, ...
					'sig'			, []		  ...
					));
	
	h.opt.showgrid		= false;
	%h.opt.setplotlimits	= false;
	
%parse the t/f/p values
	[t,f,p]	= deal(x{:});
	
	t	= reshape(t,[],1);
	f	= reshape(f,[],1);
	
	[nSignal,nSample]	= size(p);
	
	h.data.x					= {t};
	h.data.y					= {f};
	[h.data.xerr,h.data.yerr]	= deal({0});
%fill in the mins and maxes
	h.opt.xmin	= unless(h.opt.xmin,min(h.data.x{1}));
	h.opt.xmax	= unless(h.opt.xmax,max(h.data.x{1}));
	h.opt.ymin	= unless(h.opt.ymin,min(h.data.y{1}));
	h.opt.ymax	= unless(h.opt.ymax,max(h.data.y{1}));

%plot the spectrogram
	h.hI	= image(t,f,p,'Parent',h.hA);
	
	pAbsMax	= max(abs(p(:)));
	pMin	= unless(h.opt.pmin,-pAbsMax);
	pMax	= unless(h.opt.pmax,pAbsMax);
	caxis(h.hA,[pMin pMax]);
	
	set(h.hI,'CDataMapping','scaled');
	set(h.hA,'YDir','normal');
	
	lut	= MakeLUT(h.opt.lut,256);
	colormap(lut);
	
	h.hCB			= colorbar('peer',h.hA);
	cKey			= arrayfun(@num2str,get(h.hCB,'YTick'),'UniformOutput',false);
	kMiddle			= round(numel(cKey)/2);
	cKey{kMiddle}	= ['dB=' cKey{kMiddle}];
	set(h.hCB,'YTickLabel',cKey);
	
	if h.opt.ylog
		error('ylog is not implemented');
		%set(h.hA,'YScale','log');
	end

%show significant data points
 	if ~isempty(h.opt.sig)
 		set(h.hI,'AlphaData',0.25+0.75*h.opt.sig);
 	end

%------------------------------------------------------------------------------%
function optD = GetStyleDefaults(strStyle)
	switch lower(strStyle)
		case 'color'
			optD.lut	=	[
								0	0	0.5
								0	0	1
								1	1	0
								1	0	0
								0.5	0	0
							];
		case 'bw'
			optD.lut	=	[
								0	0	0
								1	1	1
							];
		otherwise
			error(['"' tostring(strStyle) '" is not a valid spectrogram plot style.']);
	end
end
%------------------------------------------------------------------------------%

end
