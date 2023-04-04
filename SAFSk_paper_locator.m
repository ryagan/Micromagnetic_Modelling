
for b = [0 , 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1]

    myFolder = append('Bz_',string(b),'.out'); %read .out folder 
    imgi = imread(append(myFolder,'\m000000.jpg')); %sky starting point (initial pos)
    imgi = rgb2gray(imgi);
    bwi = imbinarize(imgi);
    bwi = imcomplement(bwi);
    se = strel('disk',50);
    bwi = imclose(bwi,se);
    bwi = imfill(bwi,'holes');
    skyi = regionprops(bwi,'centroid');
    figure;
    imshow(bwi)
    hold
    plot (skyi(1).Centroid(1),skyi(1).Centroid(2),'b*')

    % save sky data time and Jx and remove the data at t=0
    TJdata = importdata(fullfile(myFolder,'table.txt'));
    TJdata.data(1,:) = [];
    d = size(TJdata.data);
    %Je_values = 1e8 : 0.5e11 : 4.5e11;
    SKY_info = table((zeros(d(1),1)+b), TJdata.data(:,10) ,TJdata.data(:,1),zeros(d(1),1),zeros(d(1),1),'VariableNames', {'Bz','Je','delta_t','delta_x','Vx'});

    % read jpg files 
    filePattern = fullfile(myFolder, '*.jpg');
    theFiles = dir(filePattern);
    theFiles(1)=[]; %remove m00000.jpg file from list

    for k = 1 : length(theFiles)
        fullFileName = fullfile(myFolder, theFiles(k).name);
        imgf = imread(fullFileName);       
        imgf = rgb2gray(imgf);
        bwf = imbinarize(imgf);
        bwf = imcomplement(bwf);
        bwf = bwareaopen(bwf,5);
        se = strel('disk',50);
        bwf = imclose(bwf,se);
        bwf = imfill(bwf,'holes');  % fill holes
        skyf = regionprops(bwf,'centroid');
        figure;
        imshow(bwf)
        hold
        plot (skyf(1).Centroid(1),skyf(1).Centroid(2),'b*')

        Dx = skyf(1).Centroid(1) - skyi.Centroid(1); %get the overall x-dist
        c = 1e-9; % cell cize 
        SKY_info{k,4} = Dx*c; %distance
        SKY_info{k,5} = (Dx*c)/SKY_info{k,3}; %divide ditance/time
        %V = (Dx*c)/2e-9
    end

    close all
    T = [T;SKY_info];
end