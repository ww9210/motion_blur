global sim
sim.frame_width         =   1280;
sim.frame_height        =   720;
sim.search_range        =   64; %
sim.blocksize           =   8;  % 8x8
sim.second_MV = 1;
sim.FilterDirection = 0;
sim.Filter_first_half = 1;
intersection_mv_all = zeros(25,14400,9);
for frame=24:48
    %filename            =   strcat('./Result/intersection/',int2str(frame),'.txt');
    outputname = strcat('./Result/len_2.5_intersection/',int2str(frame),'.txt');
    fprintf('reading frame %d\n',frame);
    %tic
    %   mydataread(filename,outputname,14400) ;
    %toc
    intersection_mv_all(frame-23,:,:) = load(outputname);
end


num_in_row = sim.frame_width / sim.blocksize;
num_in_col = sim.frame_height/ sim.blocksize;

frame=1;
for frame=1:25
    %blurringFlag = zeros(1,14400);
    RGB_ang_dif=zeros(sim.frame_height,sim.frame_width,3);
    for i=1:14400
        row = fix(i/num_in_row)+1;
        col = fix(mod((i-1),num_in_row)+1);
        if(intersection_mv_all(frame,i,2)==2)
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),1)=1;%yello for no blur compensation
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),2)=1;
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
        else
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),1)=0;%yello for no blur compensation
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),2)=0;
            RGB_ang_dif((row*8-7):(row*8),(col*8-7):(col*8),3)=0;
        end
    end
    mkdir('./Result/pics','two_search_flagmap');
    mkdir('./Result/pics/two_search_flagmap','2.5_intersection')
    imwrite(RGB_ang_dif,strcat('./Result/pics/two_search_flagmap/2.5_intersection/',num2str(frame+23),'.tiff'))
end