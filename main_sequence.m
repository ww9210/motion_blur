
%% inputs 
filename            =   '../Testsequenzen/yuv/test_dragon/seq1_640x360_30fps.yuv';
begin_of_frames     =   30; % 38 for most noticeable motion blur by playground
number_of_frames    =   10;
% 
% filename            =   '~/project/Testsequenzen/yuv/foreman_cif.yuv';
% begin_of_frames     =   10; % 38 for most noticeable motion blur by playground
% number_of_frames    =   10;

global sim
% sim.frame_width         =   1280;
% sim.frame_height        =   720;

sim.frame_width         =   640;
sim.frame_height        =   360;
% sim.frame_width         =   352;
% sim.frame_height        =   288;
sim.search_range        =   64; % 
sim.blocksize           =   8;  % 8x8
% sim.blocksize = 4;  % for cif
sim.second_MV = 1;
sim.FilterDirection = 0;
sim.Filter_first_half = 1;

%% read sequence
blur = cell(1,number_of_frames-2); 
luma = read_luma(filename,number_of_frames,begin_of_frames);
% chroma  = read_chroma(filename,number_of_frames,begin_of_frames);


for num = 1:number_of_frames
    current = luma{num};
    if num == 1
    % 1st frame coded alone    
    % plot frame and record blur_info
    
%     imwrite(double(current),'./Result/frames/1','jpg');
    else
        if num == 2
    % 2nd frame could only prediction 
            last = luma{1};
            last_ups = interpolation(last);
            tic
            [current_mv,current_predi] = calc_motion(last_ups,current);
            toc
            last_mv = current_mv;
        else
    % from 3rd frame general prediction
            last = current_predi;
            last_ups = interpolation(last);
            tic
            [current_mv,current_interim] = calc_motion(last_ups,current);
            toc
            acceleration = calc_acceleration(last_mv,current_mv);
            tic 
            [blur_info, current_predi] = compensate_blur(last, current,current_interim,current_mv,acceleration);
            toc
            last_mv = current_mv;
            blur{num-2} = blur_info;
            
            
            original = sum(blur_info(:,7));
            estimation = sum(blur_info(:,5)); % overall estimation including blurring    
            sum_motion = sum(blur_info(:,6));  % sum of all motion estimation (exclusive blurring) 
            blurring_part = 0; % sum of blurring part
            motion_part = 0;   % sum of motion estimation part, when blurring is applied
            num_blurring=0;    % num of blocks which use blurring
            num_motion = 0;    % num of blocks which use motion estim including blurring
            for n = 1:sim.frame_width*sim.frame_height/sim.blocksize/sim.blocksize
                if (blur_info(n,2)) 
%                 Estimation = Estimation + blur_info(n,6);
                    num_motion = num_motion+1;
                    if (blur_info(n,2)==2)
%                     sum_motion = sum_motion + blur_info(n,5);
                        blurring_part = blurring_part +  blur_info(n,5);
                        motion_part = motion_part +  blur_info(n,6);
                        num_blurring = num_blurring+1;
                    else
%                     sum_motion = sum_motion + blur_info(n,6);
                    end
%             else
%                 Estimation = Estimation + blur_info(n,7);
                end
            end
            estimation2original = estimation/original;
            estimation2sum_motion = estimation/sum_motion;
            blurring2motion = blurring_part/motion_part;
            motion2original = sum_motion/original;
        % plot frame and record blur_info
%         imwrite(current,strcat('./Result/frames/',num2str(num)),'jpg');
%             str = strcat('./Result/blurring/playground/blur_',num2str(num),'.txt');
%             str = strcat('./Result/blurring/foreman/blur_non_2nd_me_',num2str(num),'.txt');
            str = strcat('./Result/blurring/dragon_1/blur_2nd_0.5_direction',num2str(num),'.txt');
            [height, width] = size(blur_info);
            fid = fopen(str, 'wt');
            for i = 1:height
                for j = 1:width
                    fprintf(fid, '%d ', blur_info(i,j));
                end
                fprintf(fid, '%d %d', acceleration(i,2), acceleration(i,3));
                fprintf(fid, '\n');
            end
            fprintf(fid,'predi/orig = %f\n', estimation2original);
            fprintf(fid,'predi/predi_motion = %f\n', estimation2sum_motion);
            fprintf(fid,'blurpart/itsmotion = %f\n', blurring2motion); 
            fprintf(fid,'predi_motion/orig = %f\n', motion2original); 
            fprintf(fid,'num of block = %d\n', sim.frame_width*sim.frame_height/sim.blocksize/sim.blocksize);
            fprintf(fid,'num of blurring block = %d\n', num_blurring); 
            fprintf(fid,'block using ME = %d\n', num_motion); 
            fclose(fid);
        end
    end
end
