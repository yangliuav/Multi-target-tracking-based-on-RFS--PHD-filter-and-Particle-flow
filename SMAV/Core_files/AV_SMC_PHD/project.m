function p2d = project( p3d, cam, align_mat )
% This function projects 3D coordinates to 2D image plane for all 3 
% different camera angles.

% This function was downloaded from: 
% http://www.glat.info/ma/av16.3/EXAMPLES/3D-RECONSTRUCTION/index.html 

% =========================================================================
% Input:
% p3d           -   4x1 3D coordinates, these are (x, y, z, 1) world coordinates.
% cam           -   camera calibration parameters.
% align_mat     -   certain matrix transformation data.
% =========================================================================
% Output:
% p2d           -   3x3 2D coordinates of the 3D point for all camera angles.
%                   These are (col, row,1) image coordinates for one camera angle.
% =========================================================================
  
  p2d = zeros(3,3);
  ncams = length( cam );
  
  for c = 1:ncams
    
    % Project to 3D video referent
   xyz = inv( align_mat ) * p3d;
    %xyz = align_mat \ p3d;
    
    % Euclidian projection
    new_x = cam( c ).Pmat * xyz;
    new_x = new_x ./ repmat( new_x( 3,:), 3, 1 ) ;
    
    %Apply radial distortion
    new_xd = doradial( new_x, cam(c).K, cam(c).kc, cam(c).alpha_c );
    
    %p2d = [ p2d; new_xd ];
    p2d(c,:) =  new_xd' ;
  end
  