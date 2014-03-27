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
    outputname = strcat('./Result/intersection/',int2str(frame),'mv.txt');
    fprintf('reading frame %d\n',frame);
    %tic
    %   mydataread(filename,outputname,14400) ;
    %toc
    intersection_mv_all(frame-23,:,:) = load(outputname);
end


frame=1;
blurringFlag = zeros(1,14400);
for i=1:14400
    if(intersection_mv_all(frame,i,2)==2)
        
end