function acceleration = calc_acceleration(last_motion,current_motion)

% calculate acceleration

global sim

% loop from first block till last
% number of block could be calculated with motion/32 while impact of each
% block should be generated with motion%32

num_in_row = sim.frame_width / sim.blocksize;
num_in_col = sim.frame_height/ sim.blocksize;
num_block_all  = num_in_row * num_in_col;

blocksize_interpolated = sim.blocksize * 4;

acceleration = zeros(num_block_all, 19); % number of column could be more than 7

for blocknumber = 1:num_block_all
%     if blocknumber == 9
%        ; 
%     end
    if current_motion(blocknumber,2)==0        
        acceleration(blocknumber,1:3) = [blocknumber current_motion(blocknumber,3) current_motion(blocknumber,4)];
    else
        delta_x = current_motion(blocknumber,3);
        delta_y = current_motion(blocknumber,4);
    
        delta_block_x = floor(delta_x/blocksize_interpolated);
        delta_block_y = floor(delta_y/blocksize_interpolated);
    
        rest_block_x = mod(delta_x, blocksize_interpolated);
        rest_block_y = mod(delta_y, blocksize_interpolated);
    
        ratio_x = 1- rest_block_x./blocksize_interpolated;
        ratio_y = 1- rest_block_y./blocksize_interpolated;
        weight_region = [ratio_x*ratio_y (1-ratio_x)*ratio_y ratio_x*(1-ratio_y) (1-ratio_x)*(1-ratio_y)];
    
        postion_start = blocknumber+delta_block_x+delta_block_y*num_in_row;
        block_numbers = [postion_start postion_start+1 postion_start+num_in_row postion_start+num_in_row+1];
%     acceleration = [blocknumber ]

%         if(postion_start+num_in_row >14400)
%             acceleration(blocknumber,1:3) = [blocknumber current_motion(blocknumber,3) current_motion(blocknumber,4)];
%             continue;
%         end

        motion_last_frame_x = 0;
        motion_last_frame_y = 0;
        weight_all = 0;

        for i=1:4
            if last_motion(block_numbers(i),2) == 0
            
            else
                motion_last_frame_x = motion_last_frame_x+last_motion(block_numbers(i),3)*weight_region(i);
                motion_last_frame_y = motion_last_frame_y+last_motion(block_numbers(i),4)*weight_region(i);
                weight_all = weight_all+weight_region(i);
            end
            acceleration(blocknumber,4*i:4*i+3) = [block_numbers(i) last_motion(block_numbers(i),3) last_motion(block_numbers(i),4) weight_region(i)];
        end
        if weight_all==0
       % no motion from last frame 
            acceleration(blocknumber,1:3) = [blocknumber current_motion(blocknumber,3) current_motion(blocknumber,4)];
        else
       % generate motion vector and calculate acceleration 
            motion_weighted_x = motion_last_frame_x/weight_all;
            motion_weighted_y = motion_last_frame_y/weight_all;
            acceleration(blocknumber,1:3) = [blocknumber 
                    round(current_motion(blocknumber,3) - motion_weighted_x)
                    round(current_motion(blocknumber,4) - motion_weighted_y)
                    ];
       
        end
    end
    
end



