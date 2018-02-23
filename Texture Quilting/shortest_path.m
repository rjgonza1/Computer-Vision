function [path] = shortest_path(costs)

%
% given a 2D array of costs, compute the minimum cost vertical path
% from top to bottom which, at each step, either goes straight or
% one pixel to the left or right.
%
% costs:  a HxW array of costs
%
% path: a Hx1 vector containing the indices (values in 1...W) for 
%       each step along the path
%
%
%
[H, W] = size(costs);

%%% Pad matrix with columns of high values for costs(i-1,j+1) and costs(i-1, j-1) cases
memo = padarray(costs, [0 1], 10000);
%%% Contains index of prev shortest path
backtrack = nan(H, W);

%%% Fill memo array
for i = 2:H
    for j = 2:W+1
        % This ColIndex is the min index of the three indices you are
        % checking. This means this is NOT the proper index for the
        % backtrack arrays
        [localMin, ColIndex] =  min([memo(i-1,j-1), memo(i-1,j),memo(i-1,j+1)]);
        memo(i,j) = memo(i,j) + localMin;
        % ColIndex+j-3 gives you the correct index of previous shortest
        % path
        backtrack(i, j-1) = ColIndex+j-3;
    end
end

%%% Remove padded columns
memo = memo(:, 2:W+1);

%%% Init path array
path = zeros(H,1);

%%% Starting index
[val, index] = min(memo(H,:));

%%% Backtrack
for x = H:-1:1
    path(x) = index;
    index = backtrack(x, index);
end