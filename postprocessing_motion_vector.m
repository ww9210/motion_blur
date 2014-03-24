% tmp skript to modify motion_current
[row, col] = size(temp_motion);
motion_info = zeros(row, 8);

blocksize = 8;
interpolation_constant = 4;
num_in_row = 160;
num_in_col = 90;

block_position = [fix((motion_current(:,1)-1)/num_in_row) mod(motion_current(:,1)-1,num_in_row)];
motion_info(:,1:4) = [block_position(:,1)*blocksize+1 block_position(:,1)*blocksize+blocksize ...,
                      block_position(:,2)*blocksize+1 block_position(:,2)*blocksize+blocksize];
motion_info(:,5) = motion_current(:,2);
motion_info(:,6:7) = motion_current(:,3:4)./interpolation_constant;

for i = 1:row
    if motion_info(i,5) == 0
       motion_info(i,6:7) = [0,0]; 
    end
end

motion_info(:,8) = motion_current(:,5);

figure;
for k=1:row
    if (motion_info(k,5)==1)
        rectangle('Position',[motion_info(k,3),motion_info(k,1),blocksize,blocksize], 'EdgeColor', 'black', 'FaceColor', 'blue');
%     else
%         rectangle('Position',[motion_info(k,1),motion_info(k,3),blocksize,blocksize], 'EdgeColor', 'black', 'FaceColor', 'red');
    end
end
set(gca,'YDir','reverse');
title('motion estimation');   