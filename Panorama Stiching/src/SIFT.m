function SIFT(img_l, img_r)

[F_l, D_l] = SIFT_for_single_image(img_l);
[F_r, D_r] = SIFT_for_single_image(img_r);

[match_left, match_right] = MatchDescriptors(F_l, D_l, F_r, D_r);

ind = RANSAC(match_left, match_right);

PotentialCorrespondences(img_l, img_r, match_left, match_right);
InlierCorrespondences(img_l, img_r, match_left, match_right, ind);
end

function [F, D] = SIFT_for_single_image(img)

% figure;
% imshow(img, []);
% hold on
% F = vl_sift(I) computes the SIFT frames [1] (keypoints) F of the
% image I. I is a gray-scale image in single precision. Each column
% of F is a feature frame and has the format [X;Y;S;TH], where X,Y
% is the (fractional) center of the frame, S is the scale and TH is
% the orientation (in radians).
% 
% [F,D] = vl_sift(I) computes the SIFT descriptors [1] as well. Each
% column of D is the descriptor of the corresponding frame in F. A
% descriptor is a 128-dimensional vector of class UINT8.

[F, D] = vl_sift(im2single(rgb2gray(img)));
% rand_perm = randperm(size(F, 2));   % 1��1005������е�����
% rand_features_index = rand_perm(1:50);    % ȡǰ50��
% rand_features = vl_plotframe(F(:, rand_features_index));     % ���features
% set(rand_features, 'color', 'y', 'linewidth', 2);
% title('image SIFT features');

end

function [match_left, match_right] = MatchDescriptors(F_l, D_l, F_r, D_r)

% MATCHES = vl_ubcmatch(DESCR1, DESCR2) matches the two sets of SIFT
% descriptors DESCR1 and DESCR2.
% 
% [MATCHES,SCORES] = vl_ubcmatch(DESCR1, DESCR2) retuns the matches and
% also the squared Euclidean distance between the matches.
[matches, scores] = vl_ubcmatch(D_l, D_r);  % Match SIFT features
[~, sort_index] = sort(scores, 'descend');     % ��scores����
matches = matches(:, sort_index);       % ����scores��������������matches
scores = scores(sort_index);
match_left = F_l(1:2, matches(1,:));     % ��ͼmatches�������
match_right = F_r(1:2, matches(2,:));
end

function ind = RANSAC(match_left, match_right)
% choose hyperparameters
e = 0.4;
p = 0.99;
s = 6;
n = ceil(log(1-p) / log(1-(1-e)^s));    % number of iterations

% initial
inlier_count_max = 0;
s = size(match_left, 2);
inline_count = 0;
H_best = zeros(3,3);

% iterations
for i=1:n
    % pick 4 random points
    [~,index] = datasample(match_left(1,:), 4);
    l = match_left(:, index);   % 4 random points from left image features to perform H matrix
    r = match_right(:, index);  % corresponding 4 matches from the right image
    
    l1 = l(1,:); l2 = l(2,:); l3 = l(3,:); l4 = l(4,:);
    r1 = r(1,:); r2 = r(2,:); r3 = l(3,:); r4 = l(4,:);
    % Direct Linear Transformation
    M = [
           r1(1) r1(2)  1    0     0     0  -r1(1)*l1(1) -r1(2)*l1(1) -l1(1);
            0     0     0   r1(1) r1(2)  1  -r1(1)*l1(2) -r1(2)*l1(2) -l1(2);
           r2(1) r2(2)  1    0     0     0  -r2(1)*l2(1) -r2(2)*l2(1) -l2(1);
            0     0     0   r2(1) r2(2)  1  -r2(1)*l2(2) -r2(2)*l2(2) -l2(2);
           r3(1) r3(2)  1     0     0    0  -r3(1)*l3(1) -r3(2)*l3(1) -l3(1);
            0     0     0   r3(1) r3(2)  1  -r3(1)*l3(2) -r3(2)*l3(2) -l3(2);
           r4(1) r4(2)  1     0     0    0  -r4(1)*l4(1) -r4(2)*l4(1) -l4(1);
            0     0     0   r4(1) r4(2)  1  -r4(1)*l4(2) -r4(2)*l4(2) -l4(2);
        ];
    [~,~,V] = svd(M);   % solve system using singular value decomposition
    x = V(:, end);  % retreiving eigenvector corresponding to smallest eigenvalye
    
    H = [x(1:3,1)'; x(4:6,1)'; x(7:9,1)'];
    H = H / H(end);
    
    % calculating the error in order to keep the H matrix corresponding to
    % biggest number of inliners
    points1 = H*[match_right; ones(1,s)];
    
    % Normalizing
    points1 = [points1(1,:)./points1(3,:); points1(2,:)./points1(3,:); ones(1,s)];
    
    error = (points1 - [match_left; ones(1,s)]);
    error = sqrt(sum(error.^2, 1));     % eucledian distance
    inliers = error < 10;
    inlier_count = size(find(inliers), 2);  % number of inliers
    if inlier_count > inlier_count_max
        inlier_count_max = inlier_count;
        ind = fine(inliers);
        H_best = H;
    end
    
end

end

function PotentialCorrespondences(img_l, img_r, match_left, match_right)
figure
showMatchedFeatures(img_l, img_r, match_left', match_right', 'montage');
title('set of potential matches');
legent('matchedPts_left', 'matchedPts_right');
end

function InlierCorrespondences(img_l, img_r, match_left, match_right, ind)
figure
showMatchedFeatures(img_l, img_r, match_left(:,ind)', match_right(:,ind)', 'montage');
title('set of inliers');
legent('matchedPts_left', 'matchedPts_right');
end