aviobj = VideoWriter('1.avi', 'Uncompressed AVI');
open(aviobj);
for t= 1:40
    for i = 1:29
        fnameZPF = imread(['./result/ZPF/',int2str(t), '_',int2str(i),'.png']);
        fnameNPF = imread(['./result/NPF/',int2str(t), '_',int2str(i),'.png']);
        f = [fnameZPF,fnameNPF];
        writeVideo(aviobj,imresize(f, [280 624]));
        
    end
    t
end
close(aviobj);

