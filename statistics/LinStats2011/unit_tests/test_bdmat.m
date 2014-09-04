function test_bdmat

a11 = ones(2,2);         % submatrix A(1,1)
a12 = 3*ones(2,3);       % ...
a21 = 2*ones(4,2);
a22 = 4*ones(4,3);

rn = cellstr( ( 'a':'f')' );
cn = cellstr( num2str( (1:5)'));
% create a sumatrix from existing matrices and specify arbitrary
% partitioning.
A = Pmat( [ a11  a12; a21 a22 ], [2 4], [2 3], rn, cn );


B = BDmat( {A(1,1), A(1,2), A(2,1), A(2,2)} );
B(1);
B(1:2);
B(:);

B = BDmat(A(1,1));
C = BDmat(A(1,2));
[B C];

disp('passed: BDmat');

function test(A)

if norm(A) > eps(max(A(:)))
    error( 'failed: BDmat');
end