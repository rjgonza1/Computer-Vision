% average_images
set1 = dir('set1/*.jpg');
set2 = dir('set2/*.jpg');

R = 0;
G = 0;
B = 0;

%set 1: boats boats boats
for i = 1 : length(set1)
    imname = ['set1/' set1(i).name];
    nextim = imread(imname);
    nextim = im2double(nextim);
    R = R + nextim(:,:,1);
    G = G + nextim(:,:,2);
    B = B + nextim(:,:,3);
end

R = R ./ length(set1);
G = G ./ length(set1);
B = B ./ length(set1);

set1_avg = cat(3, R, G, B);

%set 2: it's a bird, it's a plane...
R = 0;
G = 0;
B = 0;

for i = 1 : length(set2)
    imname = ['set2/' set2(i).name];
    nextim = imread(imname);
    nextim = im2double(nextim);
    R = R + nextim(:,:,1);
    G = G + nextim(:,:,2);
    B = B + nextim(:,:,3);
end

R = R ./ length(set1);
G = G ./ length(set1);
B = B ./ length(set1);

set2_avg = cat(3, R, G, B);