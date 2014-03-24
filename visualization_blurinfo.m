function showtheta = visualization_blurinfo(blurring_info,frame_last_1,frame_current,frame_current_prediction,begin_of_frames)
% use: visualization(blur_info)

close all;
%imshow(frame_last_1,[0,255]);
%figure;
%imwrite(frame_last_1/255,strcat('./Result/pics/frame_last_1_frame:',num2str(begin_of_frames),'.tiff'))
%imwrite(frame_last_1/255,strcat('./Result/pics/intersection/frame_last_1_frame:',num2str(begin_of_frames),'.tiff'))
%imshow(frame_current,[0,255]);
%figure;
%imwrite(frame_current/255,strcat('./Result/pics/frame_current_frame:',num2str(begin_of_frames),'.tiff'))
%imwrite(frame_current/255,strcat('./Result/pics/intersection/frame_current_frame:',num2str(begin_of_frames),'.tiff'))
%imshow(frame_current_prediction,[0,255])
%imwrite(frame_current_prediction/255,strcat('./Result/pics/frame_current_prediction_frame:',num2str(begin_of_frames),'.tiff'))
%imwrite(frame_current_prediction/255,strcat('./Result/pics/intersection/frame_current_prediction_frame:',num2str(begin_of_frames),'.tiff'))
global sim;
num_in_row = sim.frame_width / sim.blocksize;
num_in_col = sim.frame_height/ sim.blocksize;

tmp=blurring_info(:,2);
show=zeros(sim.frame_height/sim.blocksize,sim.frame_width/sim.blocksize);
for i = 1:length(tmp)
    row = fix(i/num_in_row)+1;
    col = fix(mod((i-1),num_in_row)+1);
    show(row,col) = tmp(i);
end
show = show-1;
%show=reshape(tmp,sim.frame_height/sim.blocksize,sim.frame_width/sim.blocksize)-1;
figure;
imshow(show);


x = blurring_info(:,8);
y = blurring_info(:,9);
complex_vector = complex(x,y);
theta = angle(complex_vector)*180/pi+180;
max(theta)
min(theta)
theta = round(theta/45);
max(theta)
min(theta)
showtheta =zeros(sim.frame_height/sim.blocksize,sim.frame_width/sim.blocksize);
RGB=zeros(sim.frame_height,sim.frame_width,3);
for i = 1:length(theta)
    row = fix(i/num_in_row)+1;
    col = fix(mod((i-1),num_in_row)+1);
    if tmp(i)==2
        if theta(i)==1
            RGB((row*8-7):(row*8),(col*8-7):(col*8),1)=1;   %yello
            RGB((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
            RGB((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
        else if theta(i)==2;
                RGB((row*8-7):(row*8),(col*8-7):(col*8),1)=1;   %magenta
                RGB((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
                RGB((row*8-7):(row*8),(col*8-7):(col*8),3)=1;
            else if theta(i)==3
                    RGB((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%blue
                    RGB((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
                    RGB((row*8-7):(row*8),(col*8-7):(col*8),3)=1;
                else if theta(i)==4
                        RGB((row*8-7):(row*8),(col*8-7):(col*8),1)=0; %green
                        RGB((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
                        RGB((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
                    else if theta(i)==5
                            RGB((row*8-7):(row*8),(col*8-7):(col*8),1)=0; %cyan
                            RGB((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
                            RGB((row*8-7):(row*8),(col*8-7):(col*8),3)=1;
                        else if(theta(i)==6)
                                RGB((row*8-7):(row*8),(col*8-7):(col*8),1)=0; %black
                                RGB((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
                                RGB((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
                            else if theta(i)==7
                                    RGB((row*8-7):(row*8),(col*8-7):(col*8),1)=1; %red
                                    RGB((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
                                    RGB((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
                                else
                                    
                                    RGB((row*8-7):(row*8),(col*8-7):(col*8),1)=1;%white: no blur compensation
                                    RGB((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
                                    RGB((row*8-7):(row*8),(col*8-7):(col*8),3)=1;
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        
        RGB((row*8-7):(row*8),(col*8-7):(col*8),1)=0.4; % green theta(i)==8(-45~0)
        RGB((row*8-7):(row*8),(col*8-7):(col*8),2)=0.6;
        RGB((row*8-7):(row*8),(col*8-7):(col*8),3)=0.2;
    end
end
%figure;
%imshow(RGB);
imwrite(RGB,strcat('./Result/pics/intersection/motion_vector_angle_with_blur_compensation_frame:',num2str(begin_of_frames),'.tiff'))
%R


x = blurring_info(:,3);
y = blurring_info(:,4);
complex_vector = complex(x,y);
theta_noblur = angle(complex_vector)*180/pi+180;
theta_noblur = ceil(theta_noblur/45);
RGB_noblur=zeros(sim.frame_height,sim.frame_width,3);
for i = 1:length(theta_noblur)
    row = fix(i/num_in_row)+1;
    col = fix(mod((i-1),num_in_row)+1);
    showtheta(row,col) = theta_noblur(i);
    if theta_noblur(i)==1
        RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=1;%yello
        RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
        RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
    else if theta_noblur(i)==2;
            RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=1; %magenta
            RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
            RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=1;
        else if theta_noblur(i)==3
                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%blue
                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=1;
            else if theta_noblur(i)==4
                    RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%green
                    RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
                    RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
                else if theta_noblur(i)==5
                        RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%cyan
                        RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
                        RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=1;
                    else if theta_noblur(i)==6
                            RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%black
                            RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
                            RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
                        else if theta_noblur(i)==7
                                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=1;%red
                                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
                                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
                            else
                                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),1)=1;%white
                                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
                                RGB_noblur((row*8-7):(row*8),(col*8-7):(col*8),3)=1;
                            end
                        end
                    end
                end
            end
        end
    end
end

%figure;
%imshow(RGB_noblur);
imwrite(RGB_noblur,strcat('./Result/pics/intersection/motion_vector_angle_without_blur_compensation_frame:',num2str(begin_of_frames),'.tiff'))
%R = reshape(zeros(length(theta)),sim.frame_height/sim.blocksize,sim.frame_width/sim.blocksize);
%G = reshape(zeros(length(theta)),sim.frame_height/sim.blocksize,sim.frame_width/sim.blocksize);
%B = reshape(zeros(length(theta)),sim.frame_height/sim.blocksize,sim.frame_width/sim.blocksize);
%RGB = cat(3,R,G,B);

%a = cat(3,frame_current,frame_current,frame_current);