function extension = border_pixel(frame)
%% border pixel extension
% input: frame
% output: extended border with 4 pixels in each direction
global sim

extension = zeros(sim.frame_height+6, sim.frame_width+6);
% border pixel extension of original frame
extension(4:3+sim.frame_height, 4:sim.frame_width+3) = frame;
for i = 1:3
   extension(i,4:sim.frame_width+3) = frame(1,:);
   extension(sim.frame_height+7-i,4:sim.frame_width+3) = frame(sim.frame_height,:);
end
for j = 1:3
   extension(:,j) = extension(:,4);
   extension(:, sim.frame_width+7-j) = extension(:,sim.frame_width+3);
end
