function [xd] = doradial(xl,K,kc, alpha_c)
% This function applies radial distortion.

% This function was downloaded from: 
% http://www.glat.info/ma/av16.3/EXAMPLES/3D-RECONSTRUCTION/index.html 

% =========================================================================
% Input:
% xl        -   3xN linear pixel coordinates in the linear image (1..M, 1...N)
%               these are (col,row,1) image coordinates.
% K         -   3x3 camera calibration matrix.
% kc        -   4x1 vector of distortion parameters.
% alpha_c   -   scalar, skew distortion parameter (default: 0 ).
% =========================================================================
% Output:
% xd        -   3xN coordinates of the distorted pixel points.
% =========================================================================

  if size(xl,1) ~= 3
    error( 'doradial needs 3xN "xl" matrix of 2D points' );
  end
  
  if ~exist( 'alpha_c', 'var' )
    alpha_c = 0;
  end
  
  cc(1) = K(1,3);
  cc(2) = K(2,3);
  fc(1) = K(1,1);
  fc(2) = K(2,2);

  %%%%%%%
  % Project
%  rays = inv( K ) * xl;
  rays =  K  \ xl;
  x = [rays(1,:)./rays(3,:); rays(2,:)./rays(3,:)];

  
  %%%%%%%
  % First compute the coordinate relative to the principal point
  % before taking care of focal length
  x_distort = apply_distortion( x, kc, alpha_c );
  
  %%%%%%%%%%
  % Second multiply by focal length and add the principal point
  xd = [ fc( 1 ) * x_distort( 1,: ) + cc( 1 );
	 fc( 2 ) * x_distort( 2,: ) + cc( 2 ); 
	 ones( 1, size( xl, 2 ) ) ];
  