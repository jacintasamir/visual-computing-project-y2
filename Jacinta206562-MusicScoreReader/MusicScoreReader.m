
% quarter = imread("quarter note.png");
% half = imread("half note.png");
% whole = imread("whole note.png");
% ctime = imread("44 time.png");
% quarter = im2gray(quarter); 
% half = im2gray(half);
% whole = im2gray(whole);
% ctime = im2gray(ctime);
% quarter = ~quarter;
% half = ~half;
% whole = ~whole;
% ctime = ~ctime;
% 
% quarter = imresize(quarter,[32,32]);
% half = imresize(half,[32,32]);
% whole = imresize(whole,[32,32]);
% ctime = imresize(ctime,[32,32]);

jb = imread("JingleBells.bmp");  
tt = imread("TwinkleTwinkleLittleStar.bmp");

tiledlayout("flow");
nexttile;
imshow(jb);

jbg = rgb2gray(jb);
jbb = imbinarize(jbg);
jbinv = ~ jbb;
nexttile;
imshow(jbinv);

[height, width] = size(jbinv);
jbinv = imcrop(jbinv, [95,100,width-95,height-150]);

se = strel("line", 20, 0); %to get staff lines  
jboh = imopen(jbinv, se);  
nexttile;
imshow(jboh);

jbs = jbinv - jboh; %to remove staff lines
nexttile;
imshow(jbs);

se = strel("line", 40, 90); %to get bar lines
jbov = imopen(jbinv, se);
nexttile;
imshow(jbov);

jbss = jbs - jbov; %to remove bar lines
nexttile;
imshow(jbss);

se = strel("line", 2, 90); %to fix cuts on notes 
jbc = imclose(jbss,se);
nexttile;
imshow(jbc);

jbco = bwareaopen(jbc,4); %remove leftover spots (intersections between staff and bar lines)
nexttile;
imshow(jbco);

cc = bwconncomp(jbco);
sb = regionprops(cc,"BoundingBox"); %plot boxes around all components
nexttile;
imshow(jbco);
for i = 1 : length(sb)
    bb = sb(i).BoundingBox; 
    rectangle('Position',  bb, 'EdgeColor', 'r', 'LineWidth', 2);
end  

% fftq=fft2(double(quarter)); % features of quarter note
% qf=abs(fftq(:));
% qf=sort(qf,'descend');
% qf=qf(1:3);
% 
% ffth=fft2(double(half)); % features of half note
% hf=abs(ffth(:));
% hf=sort(hf,'descend');
% hf=hf(1:3);
% 
% fftw=fft2(double(whole)); % features of whole note
% wf=abs(fftw(:));
% wf=sort(wf,'descend');
% wf=wf(1:3);
% 
% fftct=fft2(double(ctime)); % features of time signature
% ctf=abs(fftct(:));
% ctf=sort(ctf,'descend');
% ctf=ctf(1:3);
% 
% features = [qf, hf, wf, ctf]; % 2D array of all features
% 
% for i = 1 : length(sb) %%can make this a function
%     pos = sb(i).BoundingBox;
%     img{i} = imcrop(jbco, [pos(1),pos(2),pos(3),pos(4)]); % getting image of each note
%     img{i} = imresize(img{i},[32,32]);
%     fftim=fft2(double(img{i})); %its features
%     imgf=abs(fftim(:));
%     imgf=sort(imgf,'descend');
%     imgf=imgf(1:3);
%     for j = 1 : 4
%         note(j)=sqrt((imgf(1)-features(1,j))^2+(imgf(2)-features(2,j))^2+(imgf(3)-features(3,j))^2);
%     end
%     note
%     [minr,idx]=min(note); %finding the best match, and then labelling with respective note length
%     if idx == 1
%         noteLength{i} = "quarter";
%     elseif idx == 2
%         noteLength{i} = "half";
%     elseif idx == 3
%         noteLength{i} = "whole";
%     elseif idx == 4
%         noteLength{i} = "not note";
%         timeSig{i} = i;
%     end
% end

staffcc = bwconncomp(jboh);
staffbb = regionprops(staffcc, "BoundingBox");
count = 0;
nexttile;
imshow(jboh);
for i = 5 : 10 : length(staffbb) %loop to get bases of staff (10 to skip bass clef as it is empty)
    count = count + 1;
    bb = staffbb(i).BoundingBox; 
    rectangle('Position',  bb, 'EdgeColor', 'r', 'LineWidth', 2);
    staffs{count} = bb;
end

for i = 1 : length(staffs)
    bb = staffs{i};
    bb(2) = bb(2) - 50;
    bb(4) = bb(4) + 80;
    imgh{i} = imcrop(jbco, bb);
    ledger{i} = imcrop(jboh, bb);
    nexttile;
    imshow(imgh{i});
end

for i = 1 : length(imgh) %sort bounding boxes for each strip
    bb = regionprops(imgh{i},"BoundingBox", "Extent", "Area");
    bounds = vertcat(bb.BoundingBox);
    [~, sortorder] = sortrows(bounds);
    bb = bb(sortorder);
    nexttile;
    imshow(imgh{i});
    for j = 1 : length(bb)
        if mod(j,2) == 0
            bb2 = bb(j).BoundingBox; 
            rectangle('Position',  bb2, 'EdgeColor', 'r', 'LineWidth', 2);
        else 
            bb2 = bb(j).BoundingBox; 
            rectangle('Position',  bb2, 'EdgeColor', 'g', 'LineWidth', 2);
        end
        if bb(j).Area > 150
            noteLength{j} = "not note";
        elseif bb(j).BoundingBox(4) <= 10
            noteLength{j} = "whole";
        else
            pos = bb(j).BoundingBox;
            note = imcrop(imgh{i}, [pos(1),pos(2),pos(3),pos(4)]);
            circ = imerode(note, strel('disk', 3));
            mxv = max(circ);
            if mxv == 0
                noteLength{j} = "half";
            else
                noteLength{j} = "quarter";
            end
        end
        lengthStrip{i} = cat(1,noteLength);
    end
    allLengths = cat(1,lengthStrip);
end


for i = 1 : length(ledger)
    lc = regionprops(ledger{i},"BoundingBox","Centroid");
    nexttile;
    imshow(ledger{i})
    for j = 1 : length(lc)
        bb = lc(j).BoundingBox; 
        if mod(j,2) == 0 
            rectangle('Position',  bb, 'EdgeColor', 'r', 'LineWidth', 2);
        else
            rectangle('Position',  bb, 'EdgeColor', 'g', 'LineWidth', 2);
        end
    end
end

for i = 1 : length(imgh) %get note based on distance between ledger lines
    bbl = regionprops(ledger{i},"BoundingBox");
    bb = regionprops(imgh{i},"BoundingBox");
    bounds = vertcat(bb.BoundingBox);
    [~, sortorder] = sortrows(bounds);
    bb = bb(sortorder);
    for j = 1 : length(bb)
        pos = bb(j).BoundingBox;
        cent = pos(2)+(pos(4)-pos(3));
        centl = regionprops(ledger{i},"Centroid");
        space = centl(1).Centroid(2)-centl(2).Centroid(2);
        cent6 = centl(5).Centroid(2) - space; %imaginary 6th leedger line below staff   
            if cent <= (centl(1).Centroid(2)+centl(1).Centroid(2)*0.25) && cent >= (centl(1).Centroid(2)-centl(1).Centroid(2)*0.25) %get notes on first line
                notePitch{j} = "F5";
            elseif cent <= (centl(2).Centroid(2)+centl(2).Centroid(2)*0.25) && cent >= (centl(2).Centroid(2)-centl(2).Centroid(2)*0.25)
                notePitch{j} = "D5";
            elseif cent <= (centl(3).Centroid(2)+centl(3).Centroid(2)*0.25) && cent >= (centl(3).Centroid(2)-centl(3).Centroid(2)*0.25)
                notePitch{j} = "B4";
            elseif cent <= (centl(4).Centroid(2)+centl(4).Centroid(2)*0.25) && cent >= (centl(4).Centroid(2)-centl(4).Centroid(2)*0.25)
                notePitch{j} = "G4";    
            elseif cent <= (centl(5).Centroid(2)+cen(5).Centroid(2)*0.25) && cent >= (centl(5).Centroid(2)-centl(5).Centroid(2)*0.25)
                notePitch{j} = "E4";
            elseif cent <= (cent6+cent6*0.25) && cent >= (cent6+cent6*0.25)
                notePitch{j} = "C4";
            elseif cent > centl(1).Centroid(2)
                notePitch = "G5";
            elseif cent < centl(1).Centroid(2) && cent > centl(2).Centroid(2) %get notes in first space
                notePitch{j} = "E5";
            elseif cent < centl(2).Centroid(2) && cent > centl(3).Centroid(2)
                notePitch{j} = "C5";
            elseif cent < centl(3).Centroid(2) && cent > centl(4).Centroid(2)
                notePitch{j} = "A4";
            elseif cent < centl(4).Centroid(2) && cent > centl(5).Centroid(2)
                notePitch{j} = "F4";
            elseif cent < centl(5).Centroid(2) && cent > cent6
                notePitch{j} = "D4";
            end
        pitchStrip{i} = cat(1,notePitch); 
    end
    allPitches = cat(1,pitchStrip);
end

fs = 44100; %sampling frequency/rate
for i = 1 : length(allPitches)
    for j = 1 : length(allPitches{1,i})
            if allLengths{1, i}{1, j} == "quarter"
                t = 8;
            elseif allLengths{1, i}{1, j} == "half"
                t = 4;
            elseif allLengths{1, i}{1, j} == "whole"
                t = 2;
            elseif allLengths{1, i}{1, j} == "not note"
                continue
            end
            if allPitches{1, i}{1, j} == "C4"
                p = 261.63;
            elseif allPitches{1, i}{1, j} == "D4"
                p = 2931.66;
            elseif allPitches{1, i}{1, j} == "E4"
                p = 329.63;
            elseif allPitches{1, i}{1, j} == "F4"
                p = 349.23;  
            elseif allPitches{1, i}{1, j} == "G4"
                p = 392.00;
            elseif allPitches{1, i}{1, j} == "A4"
                p = 440.00;
            elseif allPitches{1, i}{1, j} == "B4"
                p = 493.88;
            elseif allPitches{1, i}{1, j} == "C5"
                p = 523.25;
            elseif allPitches{1, i}{1, j} == "D5"
                p = 587.33;
            elseif allPitches{1, i}{1, j} == "E5"
                p = 659.25;
            elseif allPitches{1, i}{1, j} == "F5"
                p = 698.46;
            elseif allPitches{1, i}{1, j} == "G5"
                p = 782.99;
            end
        wave = sin(2*pi*p*t);
        player = audioplayer(wave,fs);
        play(player);
    end
end



    


