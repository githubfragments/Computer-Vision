function [F, D] = SIFT(img)
% SIFT scale invariant feature transform
%
% @param
% img: origin image
%
% @return
% F: feature frame [X;Y;S;TH]
%       X,Y: center of the frame
%       S: scale
%       TH: orientation
% D: descriptor of the corresponding frame in F
%    128-dimensional vector

%% SIFT
[F, D] = vl_sift(im2single(rgb2gray(img)));     % compute the SIFT frames and descriptors

%% pick random feature points
total_feature_num = 100;        % total number of picked feature points
rand_perm = randperm(size(F, 2));          % random permutation from 1~frames number
rand_features_index = rand_perm(1:total_feature_num);    % take the first 100 feature points
rand_features = F(:, rand_features_index); % random features

%% display feature points
% figure;
imshow(img, []);
hold on;
frame = vl_plotframe(rand_features);     % random features
set(frame, 'color', 'y', 'linewidth', 2);

end
