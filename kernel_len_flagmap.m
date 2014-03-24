%fspecial = get_mv('fspecial');
global sim
sim.frame_width         =   1280;
sim.frame_height        =   720;
sim.search_range        =   64; %
sim.blocksize           =   8;  % 8x8
sim.second_MV = 1;
sim.FilterDirection = 0;
sim.Filter_first_half = 1;
begin_frame = 24;
end_frame = 30;
%% read the motion vector from file
intersection_mv_all = zeros(end_frame-begin_frame+1,14400,9);
for frame=begin_frame:end_frame
    %filename            =   strcat('./Result/intersection/',int2str(frame),'.txt');
    outputname = strcat('./Result/intersection/',int2str(frame),'mv.txt');
    fprintf('reading frame %d\n',frame);
    %tic
    %   mydataread(filename,outputname,14400) ;
    %toc
    intersection_mv_all(frame-(begin_frame-1),:,:) = load(outputname);
end

len_25_intersection_mv_all = zeros(end_frame-begin_frame+1,14400,9);
for frame=begin_frame:end_frame
    %filename            =   strcat('./Result/intersection/',int2str(frame),'.txt');
    outputname = strcat('./Result/len_2.5_intersection/',int2str(frame),'.txt');
    fprintf('reading frame %d\n',frame);
    %tic
    %   mydataread(filename,outputname,14400) ;
    %toc
   len_25_intersection_mv_all(frame-(begin_frame-1),:,:) = load(outputname);
end


hybrid_result = zeros(end_frame-begin_frame+1,14400,10);
hybrid_result(:,:,1:9) = intersection_mv_all;
%% get motion_current
tic
for frame_no=1:end_frame-begin_frame+1
    %blurinfo_intersection = reshape(intersection_mv_all(frame_no,:,:),14400,9);
    %blurinfo_fspecial = reshape(len_2.5_intersection_mv_all(frame_no,:,:),14400,9);
    %hybrid_result(frame_no,:,:) = blurinfo_intersection (frame_no,:,:);
    for i = 1:14400
        hybrid_result(frame_no,i,2) = max(intersection_mv_all(frame_no,i,2),len_25_intersection_mv_all(frame_no,i,2));
        hybrid_result(frame_no,i,5) = min(intersection_mv_all(frame_no,i,5),len_25_intersection_mv_all(frame_no,i,5));
        if(hybrid_result(frame_no,i,2)==1)
            hybrid_result(frame_no,i,10)=0;
        else
            if(intersection_mv_all(frame_no,i,5)<len_25_intersection_mv_all(frame_no,i,5))
                hybrid_result(frame_no,i,10)=1;%intersection is better
            else
                hybrid_result(frame_no,i,10)=2;%intersection len 2.5 is better
            end
        end
        %blurinfo = moiton_current(:,[1,2,8,9,6]);
        
        %table=[1 2 8 9 6];
        %[n,len]=size(table);
        %motion_current=blurinfo(:,table);
    end
end
toc
show_error=sum(hybrid_result(1,:,5));
for i =2:end_frame-begin_frame+1
    show_error(end+1) = sum(hybrid_result(i,:,5));
end
show_error = int32(show_error)';
%show_error = int32(sum(hybrid_result(:,:,5)));
sum_error = int32(sum(sum(hybrid_result(:,:,5))));


%% visualize the result
for frame = 1:end_frame-begin_frame+1
    num_in_row = sim.frame_width / sim.blocksize;
    num_in_col = sim.frame_height/ sim.blocksize;
    %method_flag = hybrid_result(frame,:,10);%0 for only motion compensation
    %1 for intersection based blur kernel
    %2 for fspecial based blur kernel
    RGB_noblur=zeros(sim.frame_height,sim.frame_width,3);
    for i = 1:14400
        row = fix(i/num_in_row)+1;
        col = fix(mod((i-1),num_in_row)+1);
        if hybrid_result(frame,i,10)==0
            RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=1;%yello for no blur compensation
            RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
            RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
        else if hybrid_result(frame,i,10)==1;
                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=1; %magenta for intersection based blur kernel
                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=1;
            else if hybrid_result(frame,i,10)==2
                    RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%blue for intersection len 2.5 is better
                    RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
                    RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=1;
                    
                end
            end
            
        end
    end
    mkdir('./Result/pics/','vary_kernel_len');
    mkdir('./Result/pics/vary_kernel_len','intersection');
    imwrite(RGB_noblur,strcat('./Result/pics/vary_kernel_len/intersection/blur_compensation_compare_frame:',num2str(frame+23),'.tiff'))
end
%figure;
%imshow(RGB_noblur);
%imwrite(RGB_noblur,strcat('./Result/pics/intersection/motion_vector_angle_without_blur_compensation_frame:',num2str(begin_of_frames),'.tiff'))