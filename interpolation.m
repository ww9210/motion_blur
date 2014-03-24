function ups  = interpolation(frame)

global sim
%% interpolation based on HEVC.
% input:  frame from sequence 
% output: upsampled frame with 4x in resolution

%% coefficents: h[] for half pel, q[] for quartel pel
hfilter = [-1, 4, -11, 40, 40, -11, 4, -1];
hfilter_tran = hfilter';
qfilter = [-1, 4, -10, 58, 17, -5, 1];
qfilter_tran = qfilter';

h_vert = zeros(sim.frame_height,8); 
q_vert = zeros(sim.frame_height,7);

h_hori = zeros(8,sim.frame_width);
q_hori = zeros(7,sim.frame_width);

for i=1:sim.frame_height
    h_vert(i,:) = hfilter;
    q_vert(i,:) = qfilter;
end
for j=1:sim.frame_width
    h_hori(:,j) = hfilter_tran;
    q_hori(:,j) = qfilter_tran;
end

%% define output and interim buffer 
ups = zeros(sim.frame_height,sim.frame_width,16); % 16 layers for 16 subblock

A = frame;

%% interpolation
% 1. boundary a,b,c,d,h,n based on A
A_ext = border_pixel(A);
a = interpolate_pixel(A_ext, q_vert, 'left');
b = interpolate_pixel(A_ext, h_vert);
c = interpolate_pixel(A_ext, q_vert, 'right');
d = fix(interpolate_pixel(A_ext, q_hori, 'above'));
h = fix(interpolate_pixel(A_ext, h_hori));
n = fix(interpolate_pixel(A_ext, q_hori, 'below'));

% 2. inside e,f,g,i,j,k,p,q,r based on a,b,c
a_ext = border_pixel(a);
b_ext = border_pixel(b);
c_ext = border_pixel(c);

e = fix(interpolate_pixel(a_ext, q_hori, 'above'));
i = fix(interpolate_pixel(a_ext, h_hori));
p = fix(interpolate_pixel(a_ext, q_hori, 'below'));

f = fix(interpolate_pixel(b_ext, q_hori, 'above'));
j = fix(interpolate_pixel(b_ext, h_hori));
q = fix(interpolate_pixel(b_ext, q_hori, 'below'));

g = fix(interpolate_pixel(c_ext, q_hori, 'above'));
k = fix(interpolate_pixel(c_ext, h_hori));
r = fix(interpolate_pixel(c_ext, q_hori, 'below'));

a = fix(a);
b = fix(b);
c = fix(c);

ups(:,:,1) = A;
ups(:,:,2) = a;
ups(:,:,3) = b;
ups(:,:,4) = c;
ups(:,:,5) = d;
ups(:,:,6) = e;
ups(:,:,7) = f;
ups(:,:,8) = g;
ups(:,:,9) = h;
ups(:,:,10) = i;
ups(:,:,11) = j;
ups(:,:,12) = k;
ups(:,:,13) = n;
ups(:,:,14) = p;
ups(:,:,15) = q;
ups(:,:,16) = r;

clear a b c d e f g h i j k n p q r A_ext a_ext b_ext c_ext


