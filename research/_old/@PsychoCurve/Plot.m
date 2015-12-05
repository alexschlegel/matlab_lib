function Plot(p)
% PsychoCurve.Plot
% 
% Description:	plot the results of the probe/fit procedure
% 
% Syntax:	p.Plot
% 
% Updated: 2015-04-16
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%fit
	figure;
	
	nBin	= 10;
	szMin	= 2;
	szMax	= 40;
	
	n	= hist(p.xStim,p.x);
	if isempty(n)
		n	= ones(size(p.x));
	end
	
	t	= GetInterval(p.xmin,p.xmax,10);
	h1	= plot(t,p.P(t),'r','linewidth',3);
	
	hold on;
	
	nMax	= max(n);
	for k=1:numel(p.x)
		h	= plot(p.x(k),p.f(k),'k.','MarkerSize',round(MapValue(n(k),0,nMax,szMin,szMax)));
		
		if n(k)==nMax
			h2	= h;
		end
	end
	
	hold off;
	
	legend([h1 h2],'best fit','data');
	
	set(gca,'YLim',[0 1]);
	xlabel('stimulus');
	ylabel('mean response');
%t/b history
	figure;
	
	k			= 1:numel(p.hist.t);
	[ax,h1,h2]	= plotyy(k,p.hist.t,k,p.hist.b);
	set([h1 h2],'linewidth',3);
	
	legend('t','b');
%r2/se history
	figure;
	
	k			= 1:numel(p.hist.r2);
	[ax,h1,h2]	= plotyy(k,p.hist.r2,k,p.hist.se,@plot,@semilogy);
	set([h1 h2],'linewidth',3);
	
	legend('r^2','se');

drawnow;