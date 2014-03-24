function [u,v] = read_chroma(filename, num_of_pic, pic_begin)

global sim
%% read test sequences to matlab from YUV file.
%% input
% filename      :   yuv document, u.v components
% num_of_pic    :   number of frames to be investigated
% pic_begin     :   position of 1st frame in sequence   
% pic_width     :   width of frame
% pic_height    :   height of frame
%% output
% pic_sequence  :   cell to save the sequence needed (with consideration of
%                   GOP)

%%
u = cell(num_of_pic,1);
v = cell(num_of_pic,1);

fid = fopen(filename,'r');

for i=1:num_of_pic
    % u component
    pos_u = (i+pic_begin-1)*sim.frame_width*sim.frame_height*1.5+sim.frame_width*sim.frame_height;
    fseek(fid, pos_u, 'bof');
    tmp = fread(fid,sim.frame_width/2*sim.frame_height/2);
    tmp_matrix = zeros(sim.frame_height/2, sim.frame_width/2);    
    for j = 1:sim.frame_height/2
        tmp_matrix(j,:) = tmp( (j-1)*sim.frame_width/2+1 : (j-1)*sim.frame_width/2+sim.frame_width/2);
    end
    u{i} = tmp_matrix;
    
    % v component
    pos_v = pos_u + sim.frame_width/2*sim.frame_height/2;
    fseek(fid, pos_v, 'bof');
    tmp = fread(fid,sim.frame_width/2*sim.frame_height/2);
    tmp_matrix = zeros(sim.frame_height/2, sim.frame_width/2);    
    for j = 1:sim.frame_height/2
        tmp_matrix(j,:) = tmp( (j-1)*sim.frame_width/2+1 : (j-1)*sim.frame_width/2+sim.frame_width/2);
    end
    v{i} = tmp_matrix;
end 
fclose(fid);

