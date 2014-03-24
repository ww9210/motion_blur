function A_ext = border_pixel_block(A)

[height, width] = size(A);

A_ext = zeros(height+6, width+6);
% border pixel extension of original frameblock
A_ext(4:3+height, 4:width+3) = A;
for i = 1:3
   A_ext(i,4:width+3) = A(1,:);
   A_ext(height+7-i,4:width+3) = A(height,:);
end
for j = 1:3
   A_ext(:,j) = A_ext(:,4);
   A_ext(:, width+7-j) = A_ext(:,width+3);
end