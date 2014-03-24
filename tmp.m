% tmp_2 read and print image from platz.

Frame_75 = imread('/home/liuyiqun/project/Testsequenzen/arki30190/00000075.png');
Frame_91 = imread('/home/liuyiqun/project/Testsequenzen/arki30190/00000091.png');
Frame_90 = imread('/home/liuyiqun/project/Testsequenzen/arki30190/00000090.png');

part_75 = Frame_75(1:500,701:1200,:);
part_91 = Frame_91(101:600, 201:700,:);

figure;image(Frame_75); axis on
figure;image(Frame_90); axis on
figure;image(Frame_91); axis on