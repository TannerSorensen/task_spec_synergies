function Jstar = jacStar(J,W,G_A,Nz)

Jt = J';
C = J/W*Jt;
Im = eye(Nz);
%Jstar = pinv(J);
%Jstar = (W\Jt)/(C+(Im-G_A));
Jstar = W\(G_A*J)'/(C+(Im-G_A));

end