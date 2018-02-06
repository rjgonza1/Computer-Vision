
function [x2,y2] = applyHomography(H,x1,y1)

% [x2,y2] = applyHomography(H,x1,y1)
%
% Apply the homography transformation represented by H
%  to a set of points and return the new point coordinates.
%
% input:  
%
%   H:  a 3x3 matrix representing the homography transformation
%   x1:  Nx1 vector containing the x coordinates of the input points
%   y1:  Nx1 vector containing the y coordinates of the input points
%   
% output:
%   
%   x2: Nx1 vector containing x coordinates of the warped points
%   y2: Nx1 vector containing y coordinates of the warped points
%
%

% check the inputs
assert(all(size(x1,1)==size(y1,1)),'y1 is not the same size as x1');
assert(all(size(H)==[3,3]),'H is not 3x3')
assert(size(x1,2)==1,'x1 should be an Nx1 vector but second dimension is not 1');
assert(size(y1,2)==1,'y1 should be an Nx1 vector but second dimension is not 1');

%number of points
N = size(x1,1); 

for i = 1:N
    point_h = H*[x1(i);y1(i);1];
    x2(i,:) = point_h(1)/point_h(3);
    y2(i,:) = point_h(2)/point_h(3);
end