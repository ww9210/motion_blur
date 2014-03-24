function pic_sequence = read_luma(filename, num_of_pic, pic_begin)

global sim
%% read test sequences to matlab from YUV file.
%% input
% filename      :   yuv document, luma component
% num_of_pic    :   number of frames to be investigated
% pic_begin     :   position of 1st frame in sequence   
% pic_width     :   width of frame
% pic_height    :   height of frame
%% output
% pic_sequence  :   cell to save the sequence needed (with consideration of
%                   GOP)

%%
pic_sequence = cell(num_of_pic,1);

fid = fopen(filename,'r');
for i=1:num_of_pic
%     pic_sequence{i} = zeros(pic_height, pic_width);
    pos = (i+pic_begin-1)*sim.frame_width*sim.frame_height*1.5;
    fseek(fid, pos, 'bof');
    tmp = fread(fid,sim.frame_width*sim.frame_height);
    tmp_matrix = zeros(sim.frame_height, sim.frame_width);
    for j = 1:sim.frame_height
        tmp_matrix(j,:) = tmp( (j-1)*sim.frame_width+1 : (j-1)*sim.frame_width+sim.frame_width);
    end
    pic_sequence{i} = tmp_matrix;
end 
fclose(fid);

clear tmp_matrix;
clear tmp;

