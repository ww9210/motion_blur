function [filter_optimized, rest_error] = filter_generation(original, target, signed_M, signed_N)

%% calculate the filter coefficients using wiener filter (conditioned)
% orignial:     reference block  (blocksize+M-1)x(blocksize+N-1)
% desire:       current block    (blocksize+M-1)x(blocksize+M-1)
% M,N:          length of filter in each direction (maybe with direction info?)
% x,y:          position of block in reference frame
% data needed:  current frame and ref. frame(interpolated) 

blocksize = 4; %% only for test blocksize will be given by global coeff later

M = abs(signed_M);
N = abs(signed_N);

%% linear equation system with 10 equations (case M,N>2)
if (M>2 && N>2)
    left_akf = zeros(10,10);
    right_kkf = zeros(10,1);
%% left
%% row 1 f(0,0)
    left_akf(1,1) = korrelation(original,original,M,N,0,0,blocksize,0,0);
    for i=1:M-2 
        left_akf(1,2) = left_akf(1,2)+korrelation(original,original,M,N,0,0,blocksize,-i,0);
    end
    left_akf(1,3) = korrelation(original,original,M,N,0,0,blocksize,-M+1,0);
    for j=1:N-2
        left_akf(1,4) = left_akf(1,4)+korrelation(original,original,M,N,0,0,blocksize,0,-j);
    end
    for i=1:M-2
        for j=1:N-2
            left_akf(1,5) = left_akf(1,5)+korrelation(original,original,M,N,0,0,blocksize,-i,-j);
        end
    end
    for j=1:N-2 
        left_akf(1,6) = left_akf(1,6)+korrelation(original,original,M,N,0,0,blocksize,-M+1,-j);
    end
    left_akf(1,7) = korrelation(original,original,M,N,0,0,blocksize,0,-N+1);
    for i=1:M-2
        left_akf(1,8) = left_akf(1,8)+korrelation(original,original,M,N,0,0,blocksize,-i,-N+1);
    end
    left_akf(1,9) = korrelation(original,original,M,N,0,0,blocksize,-M+1,-N+1);
    left_akf(1,10) = 1;

%% row 2 f(-l,0)
    left_akf(2,1) = left_akf(1,2); 
    for l=1:M-2
        for i=1:M-2 
            left_akf(2,2) = left_akf(2,2)+korrelation(original,original,M,N,-l,0,blocksize,-i,0);
        end
        left_akf(2,3) = left_akf(2,3)+korrelation(original,original,M,N,-l,0,blocksize,-M+1,0);
        for j=1:N-2
            left_akf(2,4) = left_akf(2,4)+korrelation(original,original,M,N,-l,0,blocksize,0,-j);
        end
        for i=1:M-2
            for j=1:N-2
                left_akf(2,5) = left_akf(2,5)+korrelation(original,original,M,N,-l,0,blocksize,-i,-j);
            end
        end
        for j=1:N-2 
            left_akf(2,6) = left_akf(2,6)+korrelation(original,original,M,N,-l,0,blocksize,-M+1,-j);
        end
        left_akf(2,7) = left_akf(2,7)+korrelation(original,original,M,N,-l,0,blocksize,0,-N+1);
        for i=1:M-2
            left_akf(2,8) = left_akf(2,8)+ korrelation(original,original,M,N,-l,0,blocksize,-i,-N+1);
        end
        left_akf(2,9) = left_akf(2,9)+korrelation(original,original,M,N,-l,0,blocksize,-M+1,-N+1);
        left_akf(2,10) = left_akf(2,10)+1;
    end 
%% row 3 f(-M+1,0)
left_akf(3,1) = left_akf(1,3);
left_akf(3,2) = left_akf(2,3);
left_akf(3,3) = korrelation(original,original,M,N,-M+1,0,blocksize,-M+1,0);
for j=1:N-2
    left_akf(3,4) = left_akf(3,4)+korrelation(original,original,M,N,-M+1,0,blocksize,0,-j);
end
for i=1:M-2
    for j=1:N-2
        left_akf(3,5) = left_akf(3,5)+korrelation(original,original,M,N,-M+1,0,blocksize,-i,-j);
    end
end
for j=1:N-2 
    left_akf(3,6) = left_akf(3,6)+korrelation(original,original,M,N,-M+1,0,blocksize,-M+1,-j);
end
left_akf(3,7) = korrelation(original,original,M,N,-M+1,0,blocksize,0,-N+1);
for i=1:M-2
    left_akf(3,8) = left_akf(3,8)+korrelation(original,original,M,N,-M+1,0,blocksize,-i,-N+1);
end
left_akf(3,9) = korrelation(original,original,M,N,-M+1,0,blocksize,-M+1,-N+1);
left_akf(3,10) = 1;

%% row 4 f(0,-p)

left_akf(4,1) = left_akf(1,4);
left_akf(4,2) = left_akf(2,4);
left_akf(4,3) = left_akf(3,4);
for p=1:N-2
    for j=1:N-2
        left_akf(4,4) = left_akf(4,4)+korrelation(original,original,M,N,0,-p,blocksize,0,-j);
    end
    for i=1:M-2
        for j=1:N-2
            left_akf(4,5) = left_akf(4,5)+korrelation(original,original,M,N,0,-p,blocksize,-i,-j);
        end
    end
    for j=1:N-2 
        left_akf(4,6) = left_akf(4,6)+korrelation(original,original,M,N,0,-p,blocksize,-M+1,-j);
    end
    left_akf(4,7) = left_akf(4,7)+korrelation(original,original,M,N,0,-p,blocksize,0,-N+1);
    for i=1:M-2
        left_akf(4,8) = left_akf(4,8)+ korrelation(original,original,M,N,0,-p,blocksize,-i,-N+1);
    end
    left_akf(4,9) = left_akf(4,9)+korrelation(original,original,M,N,0,-p,blocksize,-M+1,-N+1);
    left_akf(4,10) = left_akf(4,10)+1;
end 

%% row 5 f(-l,-p)
left_akf(5,1) = left_akf(1,5);
left_akf(5,2) = left_akf(2,5);
left_akf(5,3) = left_akf(3,5);
left_akf(5,4) = left_akf(4,5);
for l=1:M-2
    for p=1:N-2
        for i=1:M-2
            for j=1:N-2
                left_akf(5,5) = left_akf(5,5)+korrelation(original,original,M,N,-l,-p,blocksize,-i,-j);
            end
        end
        for j=1:N-2 
            left_akf(5,6) = left_akf(5,6)+korrelation(original,original,M,N,-l,-p,blocksize,-M+1,-j);
        end
        left_akf(5,7) = left_akf(5,7)+korrelation(original,original,M,N,-l,-p,blocksize,0,-N+1);
        for i=1:M-2
            left_akf(5,8) = left_akf(5,8)+ korrelation(original,original,M,N,-l,-p,blocksize,-i,-N+1);
        end
        left_akf(5,9) = left_akf(5,9)+korrelation(original,original,M,N,-l,-p,blocksize,-M+1,-N+1);
        left_akf(5,10) = left_akf(5,10)+1;
    end
end 

%% row 6 f(-M+1,-p)
left_akf(6,1) = left_akf(1,6);
left_akf(6,2) = left_akf(2,6);
left_akf(6,3) = left_akf(3,6);
left_akf(6,4) = left_akf(4,6);
left_akf(6,5) = left_akf(5,6);

for p=1:N-2
    for j=1:N-2 
        left_akf(6,6) = left_akf(6,6)+korrelation(original,original,M,N,-M+1,-p,blocksize,-M+1,-j);
    end
    left_akf(6,7) = left_akf(6,7)+korrelation(original,original,M,N,-M+1,-p,blocksize,0,-N+1);
    for i=1:M-2
        left_akf(6,8) = left_akf(6,8)+ korrelation(original,original,M,N,-M+1,-p,blocksize,-i,-N+1);
    end
    left_akf(6,9) = left_akf(6,9)+korrelation(original,original,M,N,-M+1,-p,blocksize,-M+1,-N+1);
    left_akf(6,10) = left_akf(6,10)+1;
end 


%% row 7 f(0,-N+1)
left_akf(7,1) = left_akf(1,7);
left_akf(7,2) = left_akf(2,7);
left_akf(7,3) = left_akf(3,7);
left_akf(7,4) = left_akf(4,7);
left_akf(7,5) = left_akf(5,7);
left_akf(7,6) = left_akf(6,7);
left_akf(7,7) = korrelation(original,original,M,N,0,-N+1,blocksize,0,-N+1);
for i=1:M-2
    left_akf(7,8) = left_akf(7,8)+korrelation(original,original,M,N,0,-N+1,blocksize,-i,-N+1);
end
left_akf(7,9) = korrelation(original,original,M,N,0,-N+1,blocksize,-M+1,-N+1);
left_akf(7,10) = 1;

%% row 8 f(-l,-N+1)
left_akf(8,1) = left_akf(1,8);
left_akf(8,2) = left_akf(2,8);
left_akf(8,3) = left_akf(3,8);
left_akf(8,4) = left_akf(4,8);
left_akf(8,5) = left_akf(5,8);
left_akf(8,6) = left_akf(6,8);
left_akf(8,7) = left_akf(7,8);
for l=1:M-2
    for i=1:M-2
        left_akf(8,8) = left_akf(8,8)+ korrelation(original,original,M,N,-l,-N+1,blocksize,-i,-N+1);
    end
    left_akf(8,9) = left_akf(8,9)+korrelation(original,original,M,N,-l,-N+1,blocksize,-M+1,-N+1);
    left_akf(8,10) = left_akf(8,10)+1;
end 

%% row 9 f(-M+1,-N+1)
left_akf(9,1) = left_akf(1,9);
left_akf(9,2) = left_akf(2,9);
left_akf(9,3) = left_akf(3,9);
left_akf(9,4) = left_akf(4,9);
left_akf(9,5) = left_akf(5,9);
left_akf(9,6) = left_akf(6,9);
left_akf(9,7) = left_akf(7,9);
left_akf(9,8) = left_akf(8,9);
left_akf(9,9) = korrelation(original,original,M,N,-M+1,-N+1,blocksize,-M+1,-N+1);
left_akf(9,10) = 1;

%% row 10 lambda
left_akf(10,:) = [1 M-2 1 N-2 (M-2)*(N-2) N-2 1 M-2 1 0];

%% right
right_kkf(1,1) = korrelation(target, original, M, N, 0, 0, blocksize);
for l=1:M-2
    right_kkf(2,1) = right_kkf(2,1) + korrelation(target, original, M, N, -l, 0, blocksize);
end
right_kkf(3,1) = korrelation(target, original, M, N, -M+1, 0, blocksize);
for p=1:N-2
    right_kkf(4,1) = right_kkf(4,1) + korrelation(target, original, M, N, 0, -p, blocksize);
end
for l=1:M-2
    for p=1:N-2
        right_kkf(5,1) = right_kkf(5,1)+korrelation(target, original, M, N, -l, -p, blocksize);
    end
end
for p=1:N-2
    right_kkf(6,1) = right_kkf(6,1) + korrelation(target, original, M, N, -M+1, -p, blocksize);
end
right_kkf(7,1) = korrelation(target, original, M, N, 0, -N+1, blocksize);
for l=1:M-2
    right_kkf(8,1) = right_kkf(8,1) + korrelation(target, original, M, N, -l, -N+1, blocksize);
end
right_kkf(9,1) = korrelation(target, original, M, N, -M+1, -N+1, blocksize);
right_kkf(10,1) = 1;

%% filter 
filter_optimized = left_akf \ right_kkf;
    filter_optimized = [filter_optimized(1) repmat(filter_optimized(2), 1, M-2) filter_optimized(3);...
                   repmat(filter_optimized(4), N-2, 1) repmat(filter_optimized(5), N-2, M-2) repmat(filter_optimized(6), N-2, 1);...
                   filter_optimized(7) repmat(filter_optimized(8), 1, M-2)  filter_optimized(9)];
    interim_result = conv2(filter_optimized,original);
end

%% case N=1, M>2
if (N==1 && M>2)
    left_akf = zeros(4,4);
    right_kkf= zeros(4,1);
% left
% row 1
    left_akf(1,1) = korrelation(original,original,M,N,0,0,blocksize,0,0);
    for i=1:M-2 
        left_akf(1,2) = left_akf(1,2)+korrelation(original,original,M,N,0,0,blocksize,-i,0);
    end
    left_akf(1,3) = korrelation(original,original,M,N,0,0,blocksize,-M+1,0);
    left_akf(1,4) = 1;
% row 2 
    left_akf(2,1) = left_akf(1,2);
    for l=1:M-2
        for i=1:M-2 
            left_akf(2,2) = left_akf(2,2)+korrelation(original,original,M,N,-l,0,blocksize,-i,0);
        end
        left_akf(2,3) = left_akf(2,3)+korrelation(original,original,M,N,-l,0,blocksize,-M+1,0);
        left_akf(2,4) = left_akf(2,4)+1;
    end
% row 3
    left_akf(3,1) = left_akf(1,3);
    left_akf(3,2) = left_akf(2,3);
    left_akf(3,3) = korrelation(original,original,M,N,-M+1,0,blocksize,-M+1,0);
    left_akf(3,4) = 1;
% row 4
    left_akf(4,:) = [1 M-2 1 0];
% right
    right_kkf(1,1) = korrelation(target, original, M, N, 0, 0, blocksize);
    for i = 1:M-2
        right_kkf(2,1) = right_kkf(2,1)+korrelation(target, original, M, N, -i, 0, blocksize);
    end
    right_kkf(3,1) = korrelation(target, original, M, N, -M+1, 0, blocksize);
    right_kkf(4,1) = 1;
%% filter 
filter_optimized = left_akf \ right_kkf;
filter_optimized = [filter_optimized(1) repmat(filter_optimized(2), 1, M-2)  filter_optimized(3)];
interim_result = filter(filter_optimized,1,original')';

end

%% case M=1, N>2
if (M==1 && N>2)
    left_akf = zeros(4,4);
    right_kkf= zeros(4,1);
% left
% row 1
    left_akf(1,1) = korrelation(original,original,M,N,0,0,blocksize,0,0);
    for j=1:N-2 
        left_akf(1,2) = left_akf(1,2)+korrelation(original,original,M,N,0,0,blocksize,0,-j);
    end
    left_akf(1,3) = korrelation(original,original,M,N,0,0,blocksize,0,-N+1);
    left_akf(1,4) = 1;
% row 2 
    left_akf(2,1) = left_akf(1,2);
    for p=1:N-2
        for j=1:N-2 
            left_akf(2,2) = left_akf(2,2)+korrelation(original,original,M,N,0,-p,blocksize,0,-j);
        end
        left_akf(2,3) = left_akf(2,3)+korrelation(original,original,M,N,0,-p,blocksize,0,-N+1);
        left_akf(2,4) = left_akf(2,4)+1;
    end
% row 3
    left_akf(3,1) = left_akf(1,3);
    left_akf(3,2) = left_akf(2,3);
    left_akf(3,3) = korrelation(original,original,M,N,0,-N+1,blocksize,0,-N+1);
    left_akf(3,4) = 1;
% row 4
    left_akf(4,:) = [1 N-2 1 0];
% right
    right_kkf(1,1) = korrelation(target, original, M, N, 0, 0, blocksize);
    for j = 1:N-2
        right_kkf(2,1) = right_kkf(2,1)+korrelation(target, original, M, N, 0, -j, blocksize);
    end
    right_kkf(3,1) = korrelation(target, original, M, N, 0, -N+1, blocksize);
    right_kkf(4,1) = 1;
%% filter 
filter_optimized = left_akf \ right_kkf;
filter_optimized = [filter_optimized(1);repmat(filter_optimized(2), N-2, 1);filter_optimized(3)];
interim_result = filter(filter_optimized,1,original);
end

%% case N = 2, M >2
if N==2 && M>2
    left_akf = zeros(7,7);
    right_kkf= zeros(7,1);
% left
% row 1
    left_akf(1,1) = left_akf(1,1)+korrelation(original,original,M,N,0,0,blocksize,0,0);
    for i=1:M-2
        left_akf(1,2)= left_akf(1,2) + korrelation(original,original,M,N,0,0,blocksize,-i,0);
    end  
    left_akf(1,3) = left_akf(1,3)+korrelation(original,original,M,N,0,0,blocksize,-M+1,0);
    left_akf(1,4) = left_akf(1,4)+korrelation(original,original,M,N,0,0,blocksize,0,-1);
    for i=1:M-2
        left_akf(1,5) = left_akf(1,5)+korrelation(original,original,M,N,0,0,blocksize,-i,-1);
    end
    left_akf(1,6) = left_akf(1,6)+korrelation(original,original,M,N,0,0,blocksize,-M+1,-1);
    left_akf(1,7) = left_akf(1,7)+1;
% row 2
    left_akf(2,1) = left_akf(1,2);
for l=1:M-2
    for i=1:M-2
        left_akf(2,2)= left_akf(2,2) + korrelation(original,original,M,N,-l,0,blocksize,-i,0);
    end  
    left_akf(2,3) = left_akf(2,3)+korrelation(original,original,M,N,-l,0,blocksize,-M+1,0);
    left_akf(2,4) = left_akf(2,4)+korrelation(original,original,M,N,-l,0,blocksize,0,-1);
    for i=1:M-2
        left_akf(2,5) = left_akf(2,5)+korrelation(original,original,M,N,-l,0,blocksize,-i,-1);
    end
    left_akf(2,6) = left_akf(2,6)+korrelation(original,original,M,N,-l,0,blocksize,-M+1,-1);
    left_akf(2,7) = left_akf(2,7)+1;
end
% row 3
    left_akf(3,1) = left_akf(1,3);
    left_akf(3,2) = left_akf(2,3);
    left_akf(3,3) = left_akf(3,3)+korrelation(original,original,M,N,-M+1,0,blocksize,-M+1,0);
    left_akf(3,4) = left_akf(3,4)+korrelation(original,original,M,N,-M+1,0,blocksize,0,-1);
    for i=1:M-2
        left_akf(3,5) = left_akf(3,5)+korrelation(original,original,M,N,-M+1,0,blocksize,-i,-1);
    end
    left_akf(3,6) = left_akf(3,6)+korrelation(original,original,M,N,-M+1,0,blocksize,-M+1,-1);
    left_akf(3,7) = left_akf(3,7)+1;
% row 4
    left_akf(4,1) = left_akf(1,4);
    left_akf(4,2) = left_akf(2,4);
    left_akf(4,3) = left_akf(3,4);
    left_akf(4,4) = left_akf(4,4)+korrelation(original,original,M,N,0,-1,blocksize,0,-1);
    for i=1:M-2
        left_akf(4,5) = left_akf(4,5)+korrelation(original,original,M,N,0,-1,blocksize,-i,-1);
    end
    left_akf(4,6) = left_akf(4,6)+korrelation(original,original,M,N,0,-1,blocksize,-M+1,-1);
    left_akf(4,7) = left_akf(4,7)+1;
% row 5
    left_akf(5,1) = left_akf(1,5);
    left_akf(5,2) = left_akf(2,5);
    left_akf(5,3) = left_akf(3,5);
    left_akf(5,4) = left_akf(4,5);
for l=1:M-2
    for i=1:M-2
        left_akf(5,5) = left_akf(5,5)+korrelation(original,original,M,N,-l,-1,blocksize,-i,-1);
    end
    left_akf(5,6) = left_akf(5,6)+korrelation(original,original,M,N,-l,-1,blocksize,-M+1,-1);
    left_akf(5,7) = left_akf(5,7)+1;
end
    left_akf(6,1) = left_akf(1,6);
    left_akf(6,2) = left_akf(2,6);
    left_akf(6,3) = left_akf(3,6);
    left_akf(6,4) = left_akf(4,6);
    left_akf(6,5) = left_akf(5,6);
    left_akf(6,6) = left_akf(6,6)+korrelation(original,original,M,N,-M+1,-1,blocksize,-M+1,-1);
    left_akf(6,7) = left_akf(6,7)+1;
% row 7
    left_akf(7,:) = [1 M-2 1 1 M-2 1 0];
% right
right_kkf(1,1) = right_kkf(1,1)+korrelation(target,original,M,N,0,0,blocksize);
for l=1:M-2
    right_kkf(2,1) = right_kkf(2,1)+korrelation(target,original,M,N,-l,0,blocksize);
end
right_kkf(3,1) = right_kkf(3,1)+korrelation(target,original,M,N,-M+1,0,blocksize);
right_kkf(4,1) = right_kkf(4,1)+korrelation(target,original,M,N,0,-1,blocksize);
for l=1:M-2
    right_kkf(5,1) = right_kkf(5,1)+korrelation(target,original,M,N,-l,-1,blocksize);
end
right_kkf(6,1) = right_kkf(6,1)+korrelation(target,original,M,N,-M+1,-1,blocksize);
right_kkf(7,1) = 1;

% filter
filter_optimized = left_akf \ right_kkf;
filter_optimized = [filter_optimized(1) repmat(filter_optimized(2), 1, M-2)  filter_optimized(3);...
                    filter_optimized(4) repmat(filter_optimized(5), 1, M-2)  filter_optimized(6)];
interim_result = conv2(filter_optimized,original);

end
%% case M=2, N>2
if M==2 && N>2    
    left_akf = zeros(7,7);
    right_kkf= zeros(7,1);
% left
% row 1
    left_akf(1,1) = left_akf(1,1)+korrelation(original,original,M,N,0,0,blocksize,0,0);
    left_akf(1,2) = left_akf(1,2)+korrelation(original,original,M,N,0,0,blocksize,-1,0);
    for p=1:N-2    
        left_akf(1,3) = left_akf(1,3)+korrelation(original,original,M,N,0,0,blocksize,0,-p);
        left_akf(1,4) = left_akf(1,4)+korrelation(original,original,M,N,0,0,blocksize,-1,-p);
    end
    left_akf(1,5) = left_akf(1,5)+korrelation(original,original,M,N,0,0,blocksize,0,-N+1);
    left_akf(1,6) = left_akf(1,6)+korrelation(original,original,M,N,0,0,blocksize,-1,-N+1);
    left_akf(1,7) = left_akf(1,7)+1;
% row 2
    left_akf(2,1) = left_akf(1,2);
    left_akf(2,2) = left_akf(2,2)+korrelation(original,original,M,N,-1,0,blocksize,-1,0);
    for p=1:N-2    
        left_akf(2,3) = left_akf(2,3)+korrelation(original,original,M,N,-1,0,blocksize,0,-p);
        left_akf(2,4) = left_akf(2,4)+korrelation(original,original,M,N,-1,0,blocksize,-1,-p);
    end
    left_akf(2,5) = left_akf(2,5)+korrelation(original,original,M,N,-1,0,blocksize,0,-N+1);
    left_akf(2,6) = left_akf(2,6)+korrelation(original,original,M,N,-1,0,blocksize,-1,-N+1);
    left_akf(2,7) = left_akf(2,7)+1; 
% row 3
    left_akf(3,1) = left_akf(1,3);
    left_akf(3,2) = left_akf(2,3);
for j=1:N-2
    for p=1:N-2    
        left_akf(3,3) = left_akf(3,3)+korrelation(original,original,M,N,0,-j,blocksize,0,-p);
        left_akf(3,4) = left_akf(3,4)+korrelation(original,original,M,N,0,-j,blocksize,-1,-p);
    end
    left_akf(3,5) = left_akf(3,5)+korrelation(original,original,M,N,0,-j,blocksize,0,-N+1);
    left_akf(3,6) = left_akf(3,6)+korrelation(original,original,M,N,0,-j,blocksize,-1,-N+1);
    left_akf(3,7) = left_akf(3,7)+1;
end   

% row 4
    left_akf(4,1) = left_akf(1,4);
    left_akf(4,2) = left_akf(2,4);
    left_akf(4,3) = left_akf(3,4);
for j=1:N-2
    for p=1:N-2    
        left_akf(4,4) = left_akf(4,4)+korrelation(original,original,M,N,-1,-j,blocksize,-1,-p);
    end
    left_akf(4,5) = left_akf(4,5)+korrelation(original,original,M,N,-1,-j,blocksize,0,-N+1);
    left_akf(4,6) = left_akf(4,6)+korrelation(original,original,M,N,-1,-j,blocksize,-1,-N+1);
    left_akf(4,7) = left_akf(4,7)+1;
end   
% row 5
    left_akf(5,1) = left_akf(1,5);
    left_akf(5,2) = left_akf(2,5);
    left_akf(5,3) = left_akf(3,5);
    left_akf(5,4) = left_akf(4,5);
    left_akf(5,5) = left_akf(5,5)+korrelation(original,original,M,N,0,-N+1,blocksize,0,-N+1);
    left_akf(5,6) = left_akf(5,6)+korrelation(original,original,M,N,0,-N+1,blocksize,-1,-N+1);
    left_akf(5,7) = left_akf(5,7)+1;
% row 6
    left_akf(6,1) = left_akf(1,6);
    left_akf(6,2) = left_akf(2,6);
    left_akf(6,3) = left_akf(3,6);
    left_akf(6,4) = left_akf(4,6);
    left_akf(6,5) = left_akf(5,6);
    left_akf(6,6) = left_akf(6,6)+korrelation(original,original,M,N,-1,-N+1,blocksize,-1,-N+1);
    left_akf(6,7) = left_akf(6,7)+1;
% row 7
    left_akf(7,:) = [1 1 N-2 N-2 1 1 0];
% right
right_kkf(1,1) = right_kkf(1,1)+korrelation(target,original,M,N,0,0,blocksize);
right_kkf(2,1) = right_kkf(2,1)+korrelation(target,original,M,N,-1,0,blocksize);
for p=1:N-2
    right_kkf(3,1) = right_kkf(3,1)+korrelation(target,original,M,N,0,-p,blocksize);
    right_kkf(4,1) = right_kkf(4,1)+korrelation(target,original,M,N,-1,-p,blocksize);
end
right_kkf(5,1) = right_kkf(5,1)+korrelation(target,original,M,N,0,-N+1,blocksize);
right_kkf(6,1) = right_kkf(6,1)+korrelation(target,original,M,N,-1,-N+1,blocksize);
right_kkf(7,1) = 1;

% filter
    filter_optimized = left_akf \ right_kkf;
    filter_optimized = [filter_optimized(1) filter_optimized(2);...
                   repmat(filter_optimized(3), N-2, 1) repmat(filter_optimized(4), N-2, 1);...
                   filter_optimized(5)   filter_optimized(6)];
    interim_result = conv2(filter_optimized,original);
end    

%% case M=2, N=2
if M==2 && N==2    
    left_akf = zeros(5,5);
    right_kkf= zeros(5,1);
% left
    left_akf(1,1) = korrelation(original,original,M,N,0,0,blocksize,0,0);
    left_akf(1,2) = korrelation(original,original,M,N,0,0,blocksize,-1,0);
    left_akf(1,3) = korrelation(original,original,M,N,0,0,blocksize,0,-1);
    left_akf(1,4) = korrelation(original,original,M,N,0,0,blocksize,-1,-1);
    left_akf(1,5) = 1;
   
    left_akf(2,1) = left_akf(1,2);
    left_akf(2,2) = korrelation(original,original,M,N,-1,0,blocksize,-1,0);
    left_akf(2,3) = korrelation(original,original,M,N,-1,0,blocksize,0,-1);
    left_akf(2,4) = korrelation(original,original,M,N,-1,0,blocksize,-1,-1);
    left_akf(2,5) = 1;
    
    left_akf(3,1) = left_akf(1,3);
    left_akf(3,2) = left_akf(2,3);
    left_akf(3,3) = korrelation(original,original,M,N,0,-1,blocksize,0,-1);
    left_akf(3,4) = korrelation(original,original,M,N,0,-1,blocksize,-1,-1);
    left_akf(3,5) = 1;

    left_akf(4,1) = left_akf(1,4);
    left_akf(4,2) = left_akf(2,4);
    left_akf(4,3) = left_akf(3,4);
    left_akf(4,4) = korrelation(original,original,M,N,-1,-1,blocksize,-1,-1);
    left_akf(4,5) = 1;    
    
    left_akf(5,:) = [1 1 1 1 0];
% right
    right_kkf(1,1) = korrelation(target,original,M,N,0,0,blocksize);
    right_kkf(2,1) = korrelation(target,original,M,N,-1,0,blocksize);
    right_kkf(3,1) = korrelation(target,original,M,N,0,-1,blocksize);
    right_kkf(4,1) = korrelation(target,original,M,N,-1,-1,blocksize);
    right_kkf(5,1) = 1;
% filter
    filter_optimized = left_akf \ right_kkf;
    filter_optimized = [filter_optimized(1) filter_optimized(2);filter_optimized(3) filter_optimized(4)];
    interim_result = conv2(filter_optimized,original);
end %tested

%% case M=2, N=1
if M==2 && N==1    
    left_akf = zeros(3,3);
    right_kkf= zeros(3,1);
% left
    left_akf(1,1) = korrelation(original,original,M,N,0,0,blocksize,0,0);
    left_akf(1,2) = korrelation(original,original,M,N,0,0,blocksize,-1,0);
    left_akf(1,3) = 1;

    left_akf(2,1) = left_akf(1,2);
    left_akf(2,2) = korrelation(original,original,M,N,-1,0,blocksize,-1,0);
    left_akf(2,3) = 1;
    
    left_akf(3,:) = [1 1 0];
% right
    right_kkf(1,1) = korrelation(target,original,M,N,0,0,blocksize);
    right_kkf(2,1) = korrelation(target,original,M,N,-1,0,blocksize);
    right_kkf(3,1) = 1;   
% filter
    filter_optimized = (left_akf\right_kkf)';
    filter_optimized = filter_optimized(1:2);
    interim_result = filter(filter_optimized,1,original')';    
end  % tested

%% case M=1, N=2
if M==1 && N==2    
    left_akf = zeros(3,3);
    right_kkf= zeros(3,1);
% left
    left_akf(1,1) = korrelation(original,original,M,N,0,0,blocksize,0,0);
    left_akf(1,2) = korrelation(original,original,M,N,0,0,blocksize,0,-1);
    left_akf(1,3) = 1;

    left_akf(2,1) = left_akf(1,2);
    left_akf(2,2) = korrelation(original,original,M,N,0,-1,blocksize,0,-1);
    left_akf(2,3) = 1;
    
    left_akf(3,:) = [1 1 0];
% right
    right_kkf(1,1) = korrelation(target,original,M,N,0,0,blocksize);
    right_kkf(2,1) = korrelation(target,original,M,N,0,-1,blocksize);
    right_kkf(3,1) = 1;
    % filter
    filter_optimized = left_akf\right_kkf; 
    filter_optimized = filter_optimized(1:2); 
    interim_result = filter(filter_optimized,1,original);
end
% tested

%% case 1,1
if M==1 && N==1
   filter_optimized = 1; 
   interim_result = original;
end
% tested
rest_error = sum(sum((interim_result(N:N+blocksize-1,M:M+blocksize-1) - target(N:N+blocksize-1,M:M+blocksize-1)).^2));  


