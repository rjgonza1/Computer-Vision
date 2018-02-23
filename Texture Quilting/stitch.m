function [result] = stitch(leftI,rightI,overlap);

% 
% stitch together two grayscale images with a specified overlap
%
% leftI : the left image of size (H x W1)  
% rightI : the right image of size (H x W2)
% overlap : the width of the overlapping region.
%
% result : an image of size H x (W1+W2-overlap)
%
if (size(leftI,1)~=size(rightI,1)); % make sure the images have compatible heights
  error('left and right image heights are not compatible');
end

[HL, WL] = size(leftI);
[HR, WR] = size(rightI);
W = WL + WR - overlap;

leftStrip = leftI(:,(WL-overlap+1):WL);
rightStrip = rightI(:,1:overlap);
cost = double(abs(leftStrip-rightStrip));

seam = shortest_path(cost);
result = zeros(HL, W);

for i=1:HL
    seamPoint = seam(i);
    for j=1:W
        % If greater than seam, use right side of seam
        if j >= (WL-overlap+seam(i))
            result(i,j) = rightI(i,seamPoint);
            %next column of right side of seam
            seamPoint = seamPoint+1;
        % Else use left
        else
            result(i,j) = leftI(i,j);
        end
    end
end
% end
% dummy code that produces result by 
% simply pasting the left image over the
% right image. replace this with your own
% code!
% result = [leftI rightI(:,overlap+1:end)];



