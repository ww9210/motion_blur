function blurred = myBlurimage(original,filter_2D)
% calculate the image block after blurring

A=conv2(original,filter_2D,'same');
[height, width] = size(A);

% interpolation filter for 1/4 accuracy
hfilter = [-1, 4, -11, 40, 40, -11, 4, -1];
hfilter_tran = hfilter';
qfilter = [-1, 4, -10, 58, 17, -5, 1];
qfilter_tran = qfilter';

h_vert = zeros(height,8); 
q_vert = zeros(height,7);
h_hori = zeros(8,width);
q_hori = zeros(7,width);

for i=1:height
    h_vert(i,:) = hfilter;
    q_vert(i,:) = qfilter;
end
for j=1:width
    h_hori(:,j) = hfilter_tran;
    q_hori(:,j) = qfilter_tran;
end

% interpolation
A_ext = border_pixel_block(A);

a = interpolate_pixel_block(A_ext, q_vert, 'left');
b = interpolate_pixel_block(A_ext, h_vert, 'center');
c = interpolate_pixel_block(A_ext, q_vert, 'right');
d = fix(interpolate_pixel_block(A_ext, q_hori, 'above'));
h = fix(interpolate_pixel_block(A_ext, h_hori, 'middle'));
n = fix(interpolate_pixel_block(A_ext, q_hori, 'below'));

% 2. inside e,f,g,i,j,k,p,q,r based on a,b,c
a_ext = border_pixel_block(a);
b_ext = border_pixel_block(b);
c_ext = border_pixel_block(c);

e = fix(interpolate_pixel_block(a_ext, q_hori, 'above'));
i = fix(interpolate_pixel_block(a_ext, h_hori, 'middle'));
p = fix(interpolate_pixel_block(a_ext, q_hori, 'below'));

f = fix(interpolate_pixel_block(b_ext, q_hori, 'above'));
j = fix(interpolate_pixel_block(b_ext, h_hori, 'middle'));
q = fix(interpolate_pixel_block(b_ext, q_hori, 'below'));

g = fix(interpolate_pixel_block(c_ext, q_hori, 'above'));
k = fix(interpolate_pixel_block(c_ext, h_hori, 'middle'));
r = fix(interpolate_pixel_block(c_ext, q_hori, 'below'));

a = fix(a);
b = fix(b);
c = fix(c);

blurred(:,:,1) = A;
blurred(:,:,2) = a;
blurred(:,:,3) = b;
blurred(:,:,4) = c;
blurred(:,:,5) = d;
blurred(:,:,6) = e;
blurred(:,:,7) = f;
blurred(:,:,8) = g;
blurred(:,:,9) = h;
blurred(:,:,10) = i;
blurred(:,:,11) = j;
blurred(:,:,12) = k;
blurred(:,:,13) = n;
blurred(:,:,14) = p;
blurred(:,:,15) = q;
blurred(:,:,16) = r;