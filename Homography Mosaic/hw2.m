% load in images

% you may want to replace these with absolute paths to where you stored the images
imnames = {'atrium/IMG_1347.JPG','atrium/IMG_1348.JPG','atrium/IMG_1349.JPG'};
nimages = length(imnames);
baseim = 1; %index of the central "base" image which 

index = 1;

for i = 1:nimages
  ims{i} = im2double(imread(imnames{i}));
  %resize the image to 1/4 resolution so things run quicker while debugging your code
  ims{i} = imresize(ims{i},0.25);  
  ims_gray{i} = rgb2gray(ims{i});
  [h(i),w(i),~] = size(ims_gray{i});
end

% get corresponding points between each image and the central base image
for i = 1:nimages
   if (i ~= baseim)
     % run interactive select tool to click corresponding points on base and non-base image
     [moving, fixed] = cpselect(ims{i},ims{baseim},'Wait',true);
     
     fixed_points{index} = fixed;
     % optionally, you can also automatically refine the user clicks using cpcorr
     moving_points{index} = cpcorr(moving,fixed,ims_gray{i},ims_gray{baseim});
     index = index + 1;
   end
end


%
% verify visually that the points are good by plotting them
% overlayed on the input images.  this is a useful step for
% debugging.
%
% here is some example code to plot some points for a pair
% of images, you will need to modify this based on how you are storing the
% points etc.

% compare base image and first peripheral

% figure(1);
% subplot(2,1,1); 
% imshow(ims{baseim});
% hold on;
% plot(fixed_points{1}(1,1),fixed_points{1}(1,2),'r*',fixed_points{1}(2,1),fixed_points{1}(2,2),'b*',fixed_points{1}(3,1),fixed_points{1}(3,2),'g*',fixed_points{1}(4,1),fixed_points{1}(4,2),'y*');
% subplot(2,1,2);
% imshow(ims{2});
% hold on;
% plot(moving_points{1}(1,1),moving_points{1}(1,2),'r*',moving_points{1}(2,1),moving_points{1}(2,2),'b*',moving_points{1}(3,1),moving_points{1}(3,2),'g*',moving_points{1}(4,1),moving_points{1}(4,2),'y*');
% 
% % compare base image and second peripheral
% figure(2);
% subplot(2,1,1); 
% imshow(ims{baseim});
% hold on;
% plot(fixed_points{2}(1,1),fixed_points{2}(1,2),'r*',fixed_points{2}(2,1),fixed_points{2}(2,2),'b*',fixed_points{2}(3,1),fixed_points{2}(3,2),'g*',fixed_points{2}(4,1),fixed_points{2}(4,2),'y*');
% subplot(2,1,2);
% imshow(ims{3});
% hold on;
% plot(moving_points{2}(1,1),moving_points{2}(1,2),'r*',moving_points{2}(2,1),moving_points{2}(2,2),'b*',moving_points{2}(3,1),moving_points{2}(3,2),'g*',moving_points{2}(4,1),moving_points{2}(4,2),'y*');


% at this point it is probably a good idea to save the results of all your clicking
% out to a file so you can easily load them in again later on without having to 
% do the clicking again.
%

% save the cells that contain a matrix of points for perip images 1 & 2
% save mypts.mat fixed_points moving_points


% to reload the points:   
% load mypts.mat

% % estimate homography for each image

for i = 1:nimages
   if (i ~= baseim)
     H{i} = computeHomography(moving_points{i-1}(:,1) ,moving_points{i-1}(:,2),fixed_points{i-1}(:,1), fixed_points{i-1}(:,2));
   else
     % homography for base image is just the identity matrix
     % this lets us treat it in the same way we treat all the
     % other images in the rest of the code.
     H{i} = eye(3); 
   end
end

% compute where corners of each warped image end up

for i = 1:nimages
  % original corner coordinates based on h,w for each image
  % stored clockwise starting from the top left
  cx = [1;w(i);w(i);1];
  cy = [1;1;h(i);h(i)];
 
  % now apply the homography to get the warped corner points
  [cx_warped{i},cy_warped{i}] = applyHomography(H{i},cx,cy);

end



% find a bounding rectangle that contains all the warped image
%  corner points (e.g., using mins and maxes of the cx/cy_warped)
%
% NOTE: I suggest rounding these coordinates to integral values
%   

% upper left corner of bounding rectangle
ul_x = min(min(cell2mat(cx_warped)));
ul_y = min(min(cell2mat(cy_warped)));

% lower right corner of bounding rectangle
lr_x = max(max(cell2mat(cx_warped)));
lr_y = max(max(cell2mat(cy_warped)));

% dimensions of our output image
out_width = round(lr_x - ul_x);
out_height = round(lr_y - ul_y);

% generate a grid of pixel coordinates that range over the 
% bounding rectangle
[xx,yy] = meshgrid(ul_x:lr_x, ul_y:lr_y);  



% NOTE: at this point you may wish to verify a few things:
%
% 1. the arrays xx and yy should have size [out_height, out_width]
% 2. the values in the array xx should range from ul_x to lr_x
% 3. the values in the array yy should range from ul_y to lr_y



% Use H and interp2 to compute colors in the warped image
for i = 1:nimages
   % warp the pixel grid
   [xxq, yyq] = applyHomography(inv(H{i}), reshape(xx, [size(xx,1)*size(xx,2),1]), reshape(yy, [size(yy,1)*size(yy,2),1]));
   
   nextim = ims{i};
   % interpolate colors from the source image onto the new grid
   R = interp2(nextim(:,:,1), reshape(xxq, [size(xx,1), size(xx,2)]), reshape(yyq, [size(yy,1), size(yy,2)]));
   G = interp2(nextim(:,:,2), reshape(xxq, [size(xx,1), size(xx,2)]), reshape(yyq, [size(yy,1), size(yy,2)]));
   B = interp2(nextim(:,:,3), reshape(xxq, [size(xx,1), size(xx,2)]), reshape(yyq, [size(yy,1), size(yy,2)]));
   J{i} = cat(3,R,G,B);

   %interp2 puts NaNs outside the support of the warped image
   % let's set them to 0 so that they appear as black in 
   % our result
   J{i}(isnan(J{i})) = 0;

   % also create a binary image that tells us which pixels
   % are valid (that lie inside the warped image)
   mask{i} = ~isnan(R);  
end

for i = 1:nimages
   % blur and clip mask{i} to get an alpha map for each image
   mask{i} = double(mask{i});
   soft{i} = imfilter(mask{i}, fspecial('gaussian',120,60));
   soft_clipped{i} = soft{i}.*mask{i};
   alpha{i} = (soft_clipped{i} - .35).*mask{i};
end

sum = alpha{1} + alpha{2} + alpha{3};
% scale alpha maps to sum to 1 at every pixel location
for i = 1:nimages
    alpha{i} = alpha{i} ./ sum;
end

% % finally blend together the resulting images into the final mosaic

K = zeros(size(J{1}));
for i = 1:nimages
    K = K + J{i}.*alpha{i};
end

% display the result
figure(1); 
imagesc(K); axis image;

% % save the result to include in your writeup
% imwrite(...)
% 
% 
