num_in_row = 160;

sum_withblurring = sum(blurring_info(:,5));
sum_motion = sum(blurring_info(:,6));
sum_original = sum(blurring_info(:,7));

ratio = sum_withblurring/sum_motion;

ratio_motion = sum_motion/sum_original;

motion_estimation = 0;
motion_blurring =0;
motion_blurring_2 = 0;
motion_blurring_1 = 0;
num_2=0;
num_motion = 0;
for n = 1:14400
   if (blurring_info(n,2)) 
       motion_estimation = motion_estimation + blurring_info(n,6);
       num_motion =num_motion+1;
       if (blurring_info(n,2)==2)
           motion_blurring = motion_blurring + blurring_info(n,5);
           motion_blurring_2 = motion_blurring_2 +  blurring_info(n,5);
           motion_blurring_1 = motion_blurring_1 +  blurring_info(n,6);
           num_2 = num_2+1;
       else
           motion_blurring = motion_blurring + blurring_info(n,6);
       end
   else 
       motion_estimation = motion_estimation + blurring_info(n,7);
   end
end

ratio_blur_in_motion_estimation = motion_blurring/motion_estimation;
ratio_blurring_ratio = motion_blurring_2/motion_blurring_1;
block_position = [fix((motion_current(:,1)-1)/num_in_row) mod(motion_current(:,1)-1,num_in_row)];
blocksize = 8;
motion_info(:,1:4) = [block_position(:,1)*blocksize+1 block_position(:,1)*blocksize+blocksize ...,
                      block_position(:,2)*blocksize+1 block_position(:,2)*blocksize+blocksize];
figure;
for k=1:14400
    if (blurring_info(k,2)==1)
        rectangle('Position',[motion_info(k,3),motion_info(k,1),blocksize,blocksize], 'EdgeColor', 'black', 'FaceColor', 'blue');
    else
        if(blurring_info(k,2) == 2)
            rectangle('Position',[motion_info(k,3),motion_info(k,1),blocksize,blocksize], 'EdgeColor', 'black', 'FaceColor', 'red');   
        end
    end
end
set(gca,'YDir','reverse');
% set(gca,'color','none');
% axis off;
title('frame 91');   