function output = synth_quilt(tindex,tile_vec,tilesize,overlap)
%
% synthesize an output image given a set of tile indices
% where the tiles overlap, stitch the images together
% by finding an optimal seam between them
%
%  tindex : array containing the tile indices to use
%  tile_vec : array containing the brightness values for each tile in vectorized format
%             this will be a 2D array of dimensions  (tilesize^2) x numtiles so that 
%             each column contains the values for a given tile (see sampletiles.m)
%
%  tilesize : the size of the tiles  (should be sqrt of the size of the tile vectors)
%  overlap : overlap amount between tiles
%
%  output : the output image

if (tilesize ~= sqrt(size(tile_vec,1)))
  error('tilesize does not match the size of vectors in tile_vec');
end

% each tile contributes this much to the final output image width 
% except for the last tile in a row/column which isn't overlapped 
% by additional tiles
tilewidth = tilesize-overlap;  

% compute size of output image based on the size of the tile map
outputsize = size(tindex)*tilewidth+overlap;
[tindH, tindW] = size(tindex);
output = zeros(tindH*tilesize,outputsize(2));

% 
% stitch each row into a separate image by repeatedly calling your stitch function
% 
for i=1:tindH
    for j=1:tindW-1
        ioffset = (i-1)*tilesize;
        
        if j==1
            % Initial tile of just leftI
            leftI = tile_vec(:,tindex(i,j));
            leftI = reshape(leftI, tilesize, tilesize);
        else
            % Consecutive tiles of stitches
            leftI = output((1:tilesize)+ioffset, 1:(tilewidth*j)+overlap);
        end

        rightI = tile_vec(:,tindex(i,j+1));
        rightI = reshape(rightI, tilesize, tilesize);

        tile_image = stitch(leftI, rightI, overlap);
%         k = imshow(tile_image)
        
        output((1:tilesize)+ioffset,(1:size(tile_image,2))) = tile_image;
%         imshow(output)        
    end
end

%%% Transpose results for row stitching
output = output';

%%% Need backdrop to handle that extra row
backdrop = zeros(outputsize(1), outputsize(2));
backdrop = backdrop';

%
% now stitch the rows together into the final result 
% (I suggest calling your stitch function on transposed row 
% images and then transpose the result back)
%

for i=1:tindH-1
    if i ~= 1
        leftI = backdrop(:, 1:((tilesize*i)-(i-1)*overlap));
    else
        leftI = output(:, 1:((tilesize*i)-(i-1)*overlap));
    end
    
    rightI = output(:,(tilesize*i)+1:tilesize*(i+1));
    
    tile_image = stitch(leftI, rightI, overlap);    
    backdrop(1:size(tile_image,1),1:size(tile_image,2)) = tile_image;
%     k = imshow(backdrop);
%     waitfor(k);
end

%%% Transpose to go back to original dimensions
output = backdrop;
output = output';