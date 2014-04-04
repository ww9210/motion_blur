global sim
sim.frame_width         =   1280;
sim.frame_height        =   720;
sim.search_range        =   64; %
sim.blocksize           =   8;  % 8x8
sim.second_MV = 1;
sim.FilterDirection = 0;
sim.Filter_first_half = 1;
%% read the motion vector from file
intersection_mv_all = zeros(25,14400,9);
for frame=24:48
    %filename            =   strcat('./Result/intersection/',int2str(frame),'.txt');
    outputname = strcat('./Result/intersection/',int2str(frame),'mv.txt');
    fprintf('reading frame %d\n',frame);
    %tic
    %   mydataread(filename,outputname,14400) ;
    %toc
    intersection_mv_all(frame-23,:,:) = load(outputname);
end

close all;
%% calculate the angle of the 1st and 2nd motion vector
frame=1;
tic
for frame=1:25
    
    flag = intersection_mv_all(frame,:,2);
    
    x_1st = intersection_mv_all(frame,:,8);
    y_1st = intersection_mv_all(frame,:,9);
    x_2nd = intersection_mv_all(frame,:,3);
    y_2nd = intersection_mv_all(frame,:,4);
    
    %deal with the 1st mv
    for i = 1:14400
        if flag(i)==1
            x_1st(i)=x_2nd(i);
            y_1st(i)=y_2nd(i);
        end
    end
    complex_vector_1st = complex(x_1st,y_1st);
    complex_vector_2nd = complex(x_2nd,y_2nd);
    
    angle_1st = angle(complex_vector_1st)*180/pi+180;
    angle_2nd = angle(complex_vector_2nd)*180/pi+180;
    dif_angle = abs(angle_2nd-angle_1st);
    dif_angle(dif_angle>180) = 360-dif_angle(dif_angle>180);
    
    dif_blur_ang=0;
    for i=1:14400
        if flag(i)==2
            dif_blur_ang(end+1)=dif_angle(i);
        end
    end
    dif_int_blur_ang=round(dif_blur_ang(2:end));
    tabulate_dif_int_blur_ang=tabulate(dif_int_blur_ang);
    
    
    
    num_in_row = sim.frame_width / sim.blocksize;
    num_in_col = sim.frame_height/ sim.blocksize;
    %method_flag = hybrid_result(frame,:,10);%0 for only motion compensation
    RGB_ang_dif=zeros(sim.frame_height,sim.frame_width,3);
    for i = 1:14400
        row = fix(i/num_in_row)+1;
        col = fix(mod((i-1),num_in_row)+1);
        if flag(i)==1
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),1)=1;%yello for no blur compensation
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
        else
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%the lighter the green the better the estimation
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),3)=1-dif_angle(i)/(std(dif_angle));
        end
    end
    %imshow(RGB_ang_dif);
    
    %
    %% visualize the length of the 1st and 2nd motion vector
    
    magnitude_1st = abs(complex_vector_1st);
    %hist(magnitude_1st,100);
   % figure;
    magnitude_2nd = abs(complex_vector_2nd);
    magnitude_dif = magnitude_1st -  magnitude_2nd;
    magnitude_int_dif = int16(magnitude_dif);
    dif_blur_magnitude=0;
    for i=1:14400
        if flag(i)==2
            dif_blur_magnitude(end+1)=magnitude_dif(i);
        end
    end
    dif_blur_magnitude = dif_blur_magnitude(2:end);
    dif_int_blur_magnitude=round(dif_blur_magnitude);
    tabulate_dif_int_blur_magnitude=tabulate(dif_int_blur_magnitude);
    
    
    %% show the magnitude difference between the 1st and the 2nd mv search
    % RGB_mag_dif=zeros(sim.frame_height,sim.frame_width,3);
    % for i = 1:14400
    %     row = fix(i/num_in_row)+1;
    %     col = fix(mod((i-1),num_in_row)+1);
    %     if flag(i)==1
    %         RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),1)=1;%yello for no blur compensation
    %         RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
    %         RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
    %     else
    %         RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%yello for no blur compensation
    %         RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
    %         RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),3)=0.5-magnitude_dif(i)/(std(dif_angle));
    %     end
    % end
    % figure;
    % imshow(RGB_mag_dif);
    
    % show the magnitude of the 1st motion vector
    RGB_mag_dif=zeros(sim.frame_height,sim.frame_width,3);
    for i = 1:14400
        row = fix(i/num_in_row)+1;
        col = fix(mod((i-1),num_in_row)+1);
        if (magnitude_1st(i)>100 && magnitude_1st(i)<400)
            RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),1)=1;%yello for no blur compensation
            RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
            RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
        else
            RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%yello for no blur compensation
            RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
            RGB_mag_dif((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
        end
    end
   % figure;
   % imshow(RGB_mag_dif);
    
    
    %% show the magnitude of all the motion vectors
    RGB_mag = zeros(sim.frame_height,sim.frame_width,3);
    for i = 1:14400
        row = fix(i/num_in_row)+1;
        col = fix(mod((i-1),num_in_row)+1);
        RGB_mag((row*8-7):(row*8),(col*8-7):(col*8),1)=1-magnitude_1st(i)/std(magnitude_1st)/1.5;%yello for no blur compensation
        RGB_mag((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
        RGB_mag((row*8-7):(row*8),(col*8-7):(col*8),3)=1-magnitude_1st(i)/std(magnitude_1st)/1.5;   
    end
    %figure;
    %imshow(RGB_mag);
    mkdir('./Result/pics','mv_mag');
    imwrite(RGB_mag,strcat('./Result/pics/mv_mag/blur_compensation_compare_frame:',num2str(frame+23),'.tiff'))
    
    %% show the angle of all motion vectors
    RGB_ang = zeros(sim.frame_height,sim.frame_width,3);
    for i = 1:14400
        row = fix(i/num_in_row)+1;
        col = fix(mod((i-1),num_in_row)+1);
        RGB_ang((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%yello for no blur compensation
        RGB_ang((row*8-7):(row*8),(col*8-7):(col*8),2)=1-angle_1st(i)/360;
        RGB_ang((row*8-7):(row*8),(col*8-7):(col*8),3)=1-angle_1st(i)/360;   
    end
    mkdir('./Result/pics','mv_ang');
    imwrite(RGB_ang,strcat('./Result/pics/mv_ang/blur_compensation_compare_frame:',num2str(frame+23),'.tiff'))
    
end
toc