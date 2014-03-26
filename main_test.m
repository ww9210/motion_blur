% main skript
blur_estimation_SE_vector = 0;
motion_SE_vector = 0;
for begin_of_frames=24:48
    %% inputs
    filename            =   '../Testsequenzen/yuv/playground.yuv';
    %begin_of_frames     =   41;
    number_of_frames    =   2;
    
    global sim
    sim.frame_width         =   1280;
    sim.frame_height        =   720;
    sim.search_range        =   64; %
    sim.blocksize           =   8;  % 8x8
    sim.second_MV = 1;
    sim.FilterDirection = 0;
    sim.Filter_first_half = 1;
    
    %% read sequence
    luma = read_luma(filename,number_of_frames,begin_of_frames);
    % chroma  = read_chroma(filename,number_of_frames,begin_of_frames);
    
    %% define current frame and last frame
    frame_last_1      =   luma{1};
    frame_current     =   luma{2};  % take 2 and 3 as example. 3 frames is for acceleration
    % first investigation is about inter prediction. motion vector generation
    
    %% interpolation
    % half-pel using upsampling coeffients and 1/4-pel using average of 2
    % around
    tic
    frame_last_1_ups  = interpolation(frame_last_1);
    toc
    %% motion vector optimization
    % in calc_motion SE would be used as criterion.
    % if SE bigger than half of its own energy
    % full search? diamond search?
    % first try full search for one block and see how much time it would cost.
    
    % motion_last       =   calc_motion(frame_last_2,frame_last_1);
    
    %tic
    %[motion_current,frame_current_prediction] = calc_motion(frame_last_1_ups,frame_current);
    %toc
    
    %save(strcat('./motion_vector/',int2str(begin_of_frames),'_frame'),'motion_current','frame_current_prediction');
    load(strcat('./motion_vector/',int2str(begin_of_frames),'_frame'));
    %%Generate or read non-linear parameter
    %% motion compensation
    tic
    % [blurring_info, frame_with_blurring] = compensate_blur(frame_last_1, frame_current,frame_current_prediction,motion_current,acceleration);
    [blurring_info, frame_with_blurring] = myCompensate_blur(frame_last_1, frame_current,frame_current_prediction,motion_current);
    toc
    %%compare and calculate error
    original = sum(blurring_info(:,7));
    estimation = sum(blurring_info(:,5)); % overall estimation including blurring
    sum_motion = sum(blurring_info(:,6));  % sum of all motion estimation (exclusive blurring)
    blurring_part = 0; % sum of blurring part
    motion_part = 0;   % sum of motion estimation part, when blurring is applied
    num_blurring=0;    % num of blocks which use blurring
    num_motion = 0;    % num of blocks which use motion estim including blurring
    for n = 1:sim.frame_width*sim.frame_height/sim.blocksize/sim.blocksize
        if (blurring_info(n,2))
            %                 Estimation = Estimation + blurring_info(n,6);
            num_motion = num_motion+1;
            if (blurring_info(n,2)==2)
                %                     sum_motion = sum_motion + blurring_info(n,5);
                blurring_part = blurring_part +  blurring_info(n,5);
                motion_part = motion_part +  blurring_info(n,6);
                num_blurring = num_blurring+1;
            else
                %                     sum_motion = sum_motion + blurring_info(n,6);
            end
            %             else
            %                 Estimation = Estimation + blurring_info(n,7);
        end
    end
    estimation2original = estimation/original;
    
    
    %
    blur_estimation_SE_vector(end+1) = estimation;
    motion_SE_vector(end+1) = sum_motion;
    %
    
    
    estimation2sum_motion = estimation/sum_motion;
    blurring2motion = blurring_part/motion_part;
    motion2original = sum_motion/original;
    % plot frame and record blurring_info
    %         imwrite(current,strcat('./Result/frames/',num2str(num)),'jpg');
    % RGB=visualization_blurinfo(blurring_info,frame_last_1,frame_current,frame_current_prediction,begin_of_frames);
    str = strcat('./Result/len_3.5_intersection/',num2str(begin_of_frames),'.txt');
    [height, width] = size(blurring_info);
    fid = fopen(str, 'wt');
    for i = 1:height
        for j = 1:width
            fprintf(fid, '%d ', blurring_info(i,j));
        end
        fprintf(fid, '\n');
    end
    %fprintf(fid,'predi/orig = %f\n', estimation2original);
    %fprintf(fid,'predi/predi_motion = %f\n', estimation2sum_motion);
    %fprintf(fid,'blurpart/itsmotion = %f\n', blurring2motion);
    %fprintf(fid,'predi_motion/orig = %f\n', motion2original);
    %fprintf(fid,'num of block = %d\n', sim.frame_width*sim.frame_height/sim.blocksize/sim.blocksize);
    %fprintf(fid,'num of blurring block = %d\n', num_blurring);
    %fprintf(fid,'block using ME = %d\n', num_motion);
    fclose(fid);
end