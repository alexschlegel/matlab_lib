function [indices,vals,labels] = diffPlotCapsule(capsuleA,capsuleB)
	A				= cvtPlotCapsule2Array(capsuleA);
	B				= cvtPlotCapsule2Array(capsuleB);
	neq				= A ~= B;
	neqli			= find(neq);
	[k1 k2 k3 k4]	= ind2sub(size(neq),neqli);
	indices			= [k1 k2 k3 k4];
	vals			= [A(neqli) B(neqli)];
	[~,labels]		= cvtPlotCapsule2Array({});
end
