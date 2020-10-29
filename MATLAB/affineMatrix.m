function AFF = affineMatrix(tX, tY, tZ, rX, rY, rZ, sX, sY, sZ)
% tX,tY,tZ     TRANSLATION
% rX,rY,rZ     ROTATION
% sX,sY,sZ     SCALING

T   = [ 1   0   0   tX  ; 
        0   1   0   tY  ; 
        0   0   1   tZ  ; 
        0   0   0   1   ];
    
S   = [ sX  0   0   0   ;
        0   sY  0   0   ;
        0   0   sZ  0   ;
        0   0   0   1   ];
    
Rx  = [ 1           0           0           0   ; 
        0           cos(rX)     -sin(rX)    0   ; 
        0           sin(rX)     cos(rX)     0   ;
        0           0           0           1   ];
    
Ry  = [ cos(rY)     0           sin(rY)     0   ; 
        0           1           0           0   ; 
        -sin(rY)    0           cos(rY)     0   ;
        0           0           0           1   ];
    
Rz  = [ cos(rZ)     -sin(rZ)    0           0   ; 
        sin(rZ)     cos(rZ)     0           0   ; 
        0           0           1           0   ;
        0           0           0           1   ];
    
    AFF     = T*S*Rz*Ry*Rx;
    
    