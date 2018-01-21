function J = mydemosaic(I)
%mydemosaic - demosaic a Bayer RG/GB image to an RGB image
%
% I: RG/GB mosaic image  of size  HxW
% J: RGB image           of size  HxWx3
% For submiission: 
% call mydemosaic(im2double(imread('demosaic/IMG_1308.pgm')))

% Initialize R,G,B matrices with missing values & their respective filters
R = zeros(size(I,1), size(I, 2));
G = R;
B = R;

R(1:2:end, 1:2:end) = I(1:2:end, 1:2:end);
G(1:2:end, 2:2:end) = I(1:2:end, 2:2:end);
G(2:2:end, 1:2:end) = I(2:2:end, 1:2:end);
B(2:2:end, 2:2:end) = I(2:2:end, 2:2:end);

% Fill each matrix with the proper values using linear and bilinear
% interpolation

% Red
R(1:2:end, 2:2:end-1) = .5 .* (R(1:2:end, 1:2:end-2) + R(1:2:end, 3:2:end));
R(2:2:end-1, 1:1:end) = .5 .* (R(1:2:end-2, 1:1:end)  + R(3:2:end, 1:1:end));

% Green
% Corners
G(1, 1) = .5 .* (G(1, 2) + G(2, 1));
G(end, end) = .5 .* (G(end, end-1) + G(end-1 ,end));

% Bilinear for middle
G(2:2:end-1, 2:2:end-1) = .25 .* (G(1:2:end-2, 2:2:end-1) + G(3:2:end, 2:2:end-1) + G(2:2:end-1, 1:2:end-2) + G(2:2:end-1, 3:2:end));
G(3:2:end-1, 3:2:end-1) = .25 .* (G(2:2:end-2, 3:2:end-1) + G(4:2:end, 3:2:end-1) + G(3:2:end-1, 2:2:end-2) + G(3:2:end-1, 4:2:end));

%Blue
B(2:2:end, 3:2:end-1) = .5 .* (B(2:2:end, 2:2:end-2) + B(2:2:end, 4:2:end));
B(3:2:end-1, 2:1:end) = .5 .* (B(2:2:end-2, 2:1:end) + B(4:2:end, 2:1:end));

J = cat(3, R, G, B);