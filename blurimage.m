function blurred = blurimage(original,filter_2D, acc_x, acc_y)
% calculate the image block after blurring
% procedure: 1. blur the image with 2D filter
%            2. after conv, result longer than original block. have to
%            pay attention to the pixel position after blurring
%            3. positive -> no shift, negative -> shift with 

% 2D blurring 
temp = conv2(filter_2D, original);
[delta_y, delta_x] = size(filter_2D);

[length_y,length_x] = size(temp);

if acc_x >= 0 
    start_x = 1;
    end_x   = length_x-delta_x+1;
else
    end_x  = length_x;
    start_x = delta_x;
end

if acc_y >=0
    start_y = 1;
    end_y   = length_y-delta_y+1;        
else
    end_y  = length_y;
    start_y = delta_y;   
end
A = fix(temp(start_y:end_y,start_x:end_x));
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

% blurred storage
blurred = zeros(height,width,16);

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




