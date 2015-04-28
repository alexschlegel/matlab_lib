function m = q2m(q)
% q2m
% 
% Description:	a copy of SPM's private Q2M nifti object function to convert
%				quaternions to rotation matrices
% 
% Syntax:	m = q2m(q)
% 
% Updated: 2015-04-28
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

q	= q(1:3); %assume rigid body
w	= sqrt(1 - sum(q.^2));
x	= q(1);
y	= q(2);
z	= q(3);

if w<1e-7
    w	= 1/sqrt(x*x+y*y+z*z);
    x	= x*w;
    y	= y*w;
    z	= z*w;
    w	= 0;
end;

xx	= x*x;
yy	= y*y;
zz	= z*z;
ww	= w*w;

xy	= x*y;
xz	= x*z;
xw	= x*w;

yz	= y*z;
yw	= y*w;
zw	= z*w;

m = [
(xx-yy-zz+ww)      2*(xy-zw)      2*(xz+yw) 0
    2*(xy+zw) (-xx+yy-zz+ww)      2*(yz-xw) 0
    2*(xz-yw)      2*(yz+xw) (-xx-yy+zz+ww) 0
           0              0              0  1];
