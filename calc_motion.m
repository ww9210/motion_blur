function [motion,prediction]=calc_motion(last_ups,current)

global sim

% parameters from inputs
num_in_row = sim.frame_width / sim.blocksize;
num_in_col = sim.frame_height/ sim.blocksize;
num_block_all  = num_in_row * num_in_col;
% define outputs
motion = zeros(num_block_all, 5);      % 4 col for blocknum, inter prediction, motion vectors
prediction = zeros(sim.frame_height, sim.frame_width); % predicted result using inter prediction

% loop for blocks
for blocknum = 1:num_block_all
    % read current block  
    block_cell = (fix((blocknum-1)/num_in_row))*sim.blocksize+1;
    block_floor = block_cell + sim.blocksize-1;
    block_left = fix(mod((blocknum-1),num_in_row)*sim.blocksize+1);
    block_right = fix(mod((blocknum-1),num_in_row)*sim.blocksize+sim.blocksize);
    current_block = current(block_cell:block_floor, block_left:block_right); 
    % compare current block with those inside search range from last frame 
    % sim.search_range
    search_left  = max(1, block_left-sim.search_range);
    search_right = min(sim.frame_width-8, block_left+sim.search_range);
    search_cell  = max(1, block_cell-sim.search_range);
    search_floor = min(sim.frame_height-8, block_cell+sim.search_range);
    % record the best result and compare with threshold
    power_block = sum(sum(current_block.^2));
    
%     SE_min = min(power_block/20, 10000); 
    SE_min = power_block;
    % 10000 is given considering an average 12,5 difference for each pixel

    % full pel
    flag = 0;
    pos_x = block_left;
    pos_y = block_cell;
    pos_z = 1;
    det_x = 0;
    det_y = 0;
    for i = search_cell:1:search_floor
        for j = search_left:1:search_right
%             for k = 1:16
%                 SE = sum(sum((current_block - last_ups(i:i+sim.blocksize-1,j:j+sim.blocksize-1,k)).^2));
                SE = sum(sum((current_block - last_ups(i:i+sim.blocksize-1,j:j+sim.blocksize-1,1)).^2));
                if SE < SE_min
                   SE_min = SE;
                   flag = 1;
                   pos_x = j;
                   pos_y = i;
%                    pos_z = k;
                end
%             end
        end
    end
    
    
    if flag        
        current_x = pos_x;
        current_y = pos_y;
        det_left  = max(1, current_x-2);
        det_right = min(sim.frame_width-7, current_x+1);
        det_cell  = max(1, current_y-2);
        det_floor = min(sim.frame_height-7, current_y+1);
        for i = det_cell:1:det_floor
            for j = det_left:1:det_right
                for k = 1:16
                    SE = sum(sum((current_block - last_ups(i:i+sim.blocksize-1,j:j+sim.blocksize-1,k)).^2));
                    if SE < SE_min
                        SE_min = SE;
                        pos_x = j;
                        pos_y = i;
                        pos_z = k;
                    end
                end
            end
        end
        prediction(block_cell:block_floor, block_left:block_right) = ...,
        last_ups(pos_y:pos_y+sim.blocksize-1, ...,
                 pos_x:pos_x+sim.blocksize-1,pos_z);
        det_x = mod(pos_z-1,4);
        det_y = fix((pos_z-1)/4);    
    else
        prediction(block_cell:block_floor, block_left:block_right) = current_block;
    end
    SE_final = sum(sum((prediction(block_cell:block_floor, block_left:block_right) ...,
               - current_block).^2));
    motion(blocknum, :) = [blocknum flag (pos_x-block_left)*4+det_x (pos_y-block_cell)*4+det_y SE_final];
%     disp(blocknum);
    if mod(blocknum, num_in_row) == 0
        fprintf('%d ',fix(blocknum/num_in_row));
        if mod(blocknum, num_in_row*10) == 0
            fprintf('\n');
        end
    end
    
end

