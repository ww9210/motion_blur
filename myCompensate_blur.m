function [blurring_info, frame_with_blurring] = myCompensate_blur(...
    frame_last,frame_current,frame_current_prediction,motion_current)
% aim of the function is to blur the pointed area around and try to find
% out the best prediction result with consideration of blurring

% input :   current frame
%           current motion
%           predicted frame with motion compensation
% output:   predicted frame with consideration of motion blur 
%           blurring info incl. flag, motion vector after blurring
%           blurring_info = [blocknum flag motion*2 SE SE_previous SE_initial]

global sim
% loop of blocknumber
num_in_row = sim.frame_width / sim.blocksize;
num_in_col = sim.frame_height/ sim.blocksize;
num_block_all  = num_in_row * num_in_col;
% define outputs
blurring_info = zeros(num_block_all, 9);   
% 4 col for blocknum, flag(0-no motion, 1-pure, 2-blurring), motion vectors, error, error_of_pure_motion_comp
frame_with_blurring = zeros(sim.frame_height, sim.frame_width); % predicted result using inter prediction
% image_to_be_blurred = zeros(sim.blocksize*2, sim.blocksize*2);
blocksize_interpolated = sim.blocksize * 4;

for blocknum = 1:num_block_all
    
    block_cell = (fix((blocknum-1)/num_in_row))*sim.blocksize+1;
    block_floor = block_cell + sim.blocksize-1;
    block_left = fix(mod((blocknum-1),num_in_row)*sim.blocksize+1);
    block_right = fix(mod((blocknum-1),num_in_row)*sim.blocksize+sim.blocksize);
    
    current_block = frame_current(block_cell:block_floor, block_left:block_right);
    
    motion_comp_block = frame_current_prediction(block_cell:block_floor, block_left:block_right);
    
    SE_initial = sum(sum(current_block.^2));
    SE_previous = sum(sum((current_block-motion_comp_block).^2));
%     imageblock_to_be_blurred = zeros(sim.blocksize*4, sim.blocksize*4);

    if motion_current(blocknum,2) == 0
    % for areas where motion compensation is not used
        frame_with_blurring(block_cell:block_floor, block_left:block_right) ...
            = current_block;
        blurring_info(blocknum,1:7) = [blocknum 0 0 0 SE_initial SE_initial SE_initial];
    else
    % find out the region to be blurred, blurring region temporarily
    % defined as 16 macroblocks around
    % use motion_current
        delta_x = motion_current(blocknum,3);
        delta_y = motion_current(blocknum,4);
        delta_block_x = floor(delta_x/blocksize_interpolated);
        delta_block_y = floor(delta_y/blocksize_interpolated);

        
        
        imageblock_cell = block_cell+(delta_block_y-1)*sim.blocksize;
        imageblock_floor = min(imageblock_cell + 4*sim.blocksize-1,sim.frame_height);
        imageblock_left = block_left+(delta_block_x-1)*sim.blocksize;
        imageblock_right = min(imageblock_left + 4*sim.blocksize-1,sim.frame_width);
         
        
        imageblock_cell = max(imageblock_cell,1);
        imageblock_left = max(imageblock_left,1);
        imageblock_to_be_blurred = frame_last(imageblock_cell:imageblock_floor,...
                                              imageblock_left:imageblock_right);
    % predefine blurring kernel to length of 50, coefficients?
        % x direction
        % y direction
    % generate blurring for block
        % filters
        blur_filter_2D = myBlurfilter(motion_current(blocknum,3),motion_current(blocknum,4),4);
        % blurring
    % blurring image block  
    % &
    % interpolationbuchholz kleefeld
    % imageblock_blurred has 16 layers to describe 1/4 pel accuracy
        imageblock_blurred = myBlurimage(imageblock_to_be_blurred,blur_filter_2D);
    % search and compare results of blurring with unblurred ones
    
        [imageblock_height,imageblock_width, imageblock_layer] = size(imageblock_blurred);
    
        SE_min = SE_previous;
        flag = 1;

%  2nd search for Motion Vector  
        if sim.second_MV        
            
            pos_x = 1; % pos_x ranged by imageblock
            pos_y = 1; % pos_y ranged by imageblock
            pos_z = 1; % pos_z 1-16
%         det_x = 0;
%         det_y = 0;

            for i= 1:(imageblock_height-sim.blocksize+1)
                for j= 1:(imageblock_width-sim.blocksize+1)
                    for k=1:16
                        SE = sum(sum((current_block - ...
                            imageblock_blurred(i:i+sim.blocksize-1,j:j+sim.blocksize-1,k)).^2));
                        if SE < SE_min
                            SE_min = SE;
                            flag = 2;
                            pos_x = j;
                            pos_y = i;
                            pos_z = k;
                        end
                    end
                end
            end

            if flag == 2
                frame_with_blurring(block_cell:block_floor, block_left:block_right) ...
                    = imageblock_blurred(pos_y:pos_y+sim.blocksize-1, ...,
                                           pos_x:pos_x+sim.blocksize-1,pos_z);
            % calculation of real motion after blurring 
                det_x = mod(pos_z-1,4);
                det_y = fix((pos_z-1)/4);                               
                motion_y = (- block_cell + imageblock_cell + pos_y-1)*4 + det_y;
                motion_x = (- block_left + imageblock_left + pos_x-1)*4 + det_x;
                blurring_info(blocknum,:) = [blocknum 2 motion_x motion_y...
                                    SE_min SE_previous SE_initial motion_current(blocknum,3) motion_current(blocknum,4)];                                  
            else
                frame_with_blurring(block_cell:block_floor, block_left:block_right) ...
                = motion_comp_block;
                blurring_info(blocknum,1:7) = [blocknum 1 motion_current(blocknum,3) motion_current(blocknum,4)...
                                    SE_min SE_previous SE_initial];        
            end
%         end
        else
            devi_x = mod(motion_current(blocknum,3),blocksize_interpolated);
            devi_y = mod(motion_current(blocknum,4),blocksize_interpolated);
        
            devi_pos_x = floor(devi_x/4);
            devi_pos_y = floor(devi_y/4);
            devi_res_x = mod(devi_x,4);
            devi_res_y = mod(devi_y,4);
            k = devi_res_x*4+devi_res_y+1;
            
            SE = sum(sum((current_block-imageblock_blurred(devi_pos_y+sim.blocksize+1:devi_pos_y+sim.blocksize*2,...
                devi_pos_x+sim.blocksize+1:devi_pos_x+sim.blocksize*2,k)).^2));
            if SE < SE_min
               flag = 2;
               SE_min = SE;
            end
            if flag == 2
               blurring_info(blocknum,:) = [blocknum 2 motion_current(blocknum,3) motion_current(blocknum,4)...
                                    SE_min SE_previous SE_initial motion_current(blocknum,3) motion_current(blocknum,4)]; 
            else
                frame_with_blurring(block_cell:block_floor, block_left:block_right) ...
                = motion_comp_block;
                blurring_info(blocknum,1:7) = [blocknum 1 motion_current(blocknum,3) motion_current(blocknum,4)...
                                    SE_min SE_previous SE_initial];        
            end
         
        end


    end
    if mod(blocknum, num_in_row) == 0
        fprintf('%d ',fix(blocknum/num_in_row));
        if mod(blocknum, num_in_row*10) == 0
            fprintf('\n');
        end
    end
end