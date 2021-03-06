function FeaturePointsVisualization(img, rows, cols, radiuses)
% Visualize for feature points detected by LoGDetector
% use the center of the circle to indicate the spatial position of the point 
% and use the radius of the circle to indicate the characteristic scale of the point
% 
% @param
% img: origin image which use to display the circle
% rows: x coordinate of feature points
% cols: y coordinate of feature points
% radiuses: characteristic scale of the point

img = rgb2gray(img);
figure;
imshow(img);
hold on;

theta = 0:pi/40:2*pi;
X = rows + sin(theta) .* radiuses;
Y = cols + cos(theta) .* radiuses;
line(Y', X', 'Color', 'r');

title(sprintf('%d feature points', size(radiuses, 1)));

end