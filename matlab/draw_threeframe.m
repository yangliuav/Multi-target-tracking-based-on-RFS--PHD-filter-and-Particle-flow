aviobj = VideoWriter('4.avi');
open(aviobj);
h = figure(2);
set(gcf, 'Position', [0, 0, 1200, 1100]);
% fnameTrue = imread(['./result/1/','Ground True.bmp']); 
for t= 1:40
    fnameZPF = imread(['./result/4/ZPF/',int2str(t), '_a.png']);
    fnameNPF = imread(['./result/4/NPF/',int2str(t), '_a.png']);
    fnameSMC = imread(['./result/4/SMC/',int2str(t), '_a.png']);  
    fnameNPFS = imread(['./result/4/NPFS/',int2str(t), '_a.png']);
    subplot('Position',[(1-1)*1/2 1/2 1/2 1/2])
    imshow(fnameNPFS);
    subplot('Position',[(2-1)*1/2 1/2 1/2 1/2])
    imshow(fnameSMC);
    subplot('Position',[0 0 1/2 1/2])
    imshow(fnameZPF);
    subplot('Position',[1/2 0 1/2 1/2])
    imshow(fnameNPF);
    F = getframe(h);
    writeVideo(aviobj,F.cdata);
    for i = 1:29
        fnameZPF = imread(['./result/4/ZPF/',int2str(t), '_',int2str(i),'.png']);
        fnameNPF = imread(['./result/4/NPF/',int2str(t), '_',int2str(i),'.png']);
        fnameNPFS = imread(['./result/4/NPFS/',int2str(t), '_',int2str(i),'.png']);
        subplot('Position',[(1-1)*1/2 1/2 1/2 1/2])
        imshow(fnameSMC);
        subplot('Position',[(2-1)*1/2 1/2 1/2 1/2])
        imshow(fnameZPF);
        subplot('Position',[0 0 1/2 1/2])
        imshow(fnameNPFS);
        subplot('Position',[1/2 0 1/2 1/2])
        imshow(fnameNPF);
    F = getframe(h);
    writeVideo(aviobj,F.cdata);
        
    end
    
    fnameZPF = imread(['./result/4/ZPF/',int2str(t), '_b.png']);
    fnameNPF = imread(['./result/4/NPF/',int2str(t), '_b.png']);
    fnameNPFS = imread(['./result/4/NPFS/',int2str(t), '_b.png']);
    fnameSMC = imread(['./result/4/SMC/',int2str(t), '_b.png']);    
    subplot('Position',[(1-1)*1/2 1/2 1/2 1/2])
    imshow(fnameSMC);
    subplot('Position',[(2-1)*1/2 1/2 1/2 1/2])
    imshow(fnameZPF);
    subplot('Position',[0 0 1/2 1/2])
    imshow(fnameNPFS);
    subplot('Position',[1/2 0 1/2 1/2])
    imshow(fnameNPF);
    F = getframe(h);
    writeVideo(aviobj,F.cdata);
    
    fnameZPF = imread(['./result/4/ZPF/',int2str(t), '_c.png']);
    fnameNPF = imread(['./result/4/NPF/',int2str(t), '_c.png']);
    fnameNPFS = imread(['./result/4/NPFS/',int2str(t), '_c.png']);
    fnameSMC = imread(['./result/4/SMC/',int2str(t), '_c.png']);    
    subplot('Position',[(1-1)*1/2 1/2 1/2 1/2])
    imshow(fnameSMC);
    subplot('Position',[(2-1)*1/2 1/2 1/2 1/2])
    imshow(fnameZPF);
    subplot('Position',[0 0 1/2 1/2])
    imshow(fnameNPFS);
    subplot('Position',[1/2 0 1/2 1/2])
    imshow(fnameNPF);
    F = getframe(h);
    writeVideo(aviobj,F.cdata);
    %writeVideo(aviobj,imresize(gcf, [280 624]));
    t
end
close(aviobj);

