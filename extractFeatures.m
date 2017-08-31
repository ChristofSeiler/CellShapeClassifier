function [M BWdfill Overlay Urelaxed]  = extractFeatures(I,plot)
%I = imread('Exp18Myo_A1_1_2009y11m13d_04h00m.jpg');

%% read image
%I_gr = rgb2gray(I);
%if(plot) figure, imshow(I_gr), title('Original image'); end

I_gr = I;

%% detect entire cell
[junk threshold] = edge(I_gr, 'sobel');
fudgeFactor = .2;
BWs = edge(I_gr,'sobel', threshold * fudgeFactor);
if(plot) figure, imshow(BWs), title('Binary gradient mask'); end

%% dilate the image
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]);
if(plot) figure, imshow(BWsdil), title('Dilated gradient mask'); end

%% remove connected objects on border
BWnobord = imclearborder(BWsdil, 4);
if(plot) figure, imshow(BWnobord), title('Cleared border image'); end

%% smoothen the object
seD = strel('diamond',1);
BWsmooth = imerode(BWnobord,seD);
BWsmooth = imerode(BWsmooth,seD);
if(plot) figure, imshow(BWsmooth), title('Segmented image'); end

%% remove small objects
BWnosmall = bwareaopen(BWsmooth, 800);
if(plot) figure, imshow(BWnosmall), title('Remove small objects'); end

%% fill interior gaps
BWdfill = imfill(BWnosmall, 'holes');
if(plot) figure, imshow(BWdfill), title('Binary image with filled holes'); end

%% plot overlay
BWoutline = bwperim(BWdfill);
Overlay = I_gr;
Overlay(BWoutline) = 255;
if(plot) figure, imshow(Overlay), title('Outlined original image'); end
%imwrite(Segout,'segmented_cells.png','png')

%% distance transform
D = bwdist(~BWdfill);
Segout = D;
Segout(BWoutline) = 15;
%figure, imshow(Segout,[]), title('Distance transform of ~BWdfill');

%% poisson equation classifier
U = GMGmain(BWdfill);
Urelaxed = relaxAfterSolvingU(U);
[UX,UY] = gradient(Urelaxed);
Phi = Urelaxed + UX.^2 + UY.^2;
Philog = immultiply(log10(Phi), BWdfill);
Philog = Philog + 10*~BWdfill;

%% poisson equation thresholding
Philog_thres = 1.6 > Philog;
Segout = Philog_thres;
Segout(BWoutline) = 1;
if(plot) figure, imshow(Segout), title('Relaxed solution to Poisson equation of ~BWdfill'); end
%imwrite(Segout,'finger_poisson_equation.png','png')

%% identify cells
cells = ~Philog_thres & BWdfill;
cells = bwareaopen(cells, 200);
[L num] = bwlabel(cells);
if(plot) figure, imshow(label2rgb(L)), title('Cells without connectors'); end
%imwrite(cells,'cells_without_fingers.png','png');

%% measurements: pixel, diameter, etc
stats = regionprops(L, 'Area', 'MajorAxisLength', 'MinorAxisLength', 'Perimeter', 'Eccentricity', 'Extent', 'EquivDiameter');
area = cat(1, stats.Area);
maxLength = cat(1, stats.MajorAxisLength);
minLength = cat(1, stats.MinorAxisLength);
perimeter = cat(1, stats.Perimeter);
ecc = cat(1, stats.Eccentricity);
extent = cat(1, stats.Extent);
diameter = cat(1, stats.EquivDiameter);
M = [area maxLength minLength perimeter ecc extent diameter];

%% measurements: connectors
fingers = 1.6 <= Philog;
fingers_conn = bwareaopen(~fingers, 30);
if(plot) figure, imshow(fingers_conn), title('Cells connectors'); end
%imwrite(fingers_conn,'cell_fingers.png','png');
numConn = zeros(1,1);
for i=1:num
    single_cell = bwperim(L==i);
    [row col] = find(single_cell == 1);
    for j=1:length(row)
        up = [row(j)+1 col(j)];
        down = [row(j)-1 col(j)];
        left = [row(j) col(j)-1];
        right = [row(j) col(j)+1];
        counter = fingers_conn(up(1),up(2)) + fingers_conn(down(1),down(2)) + fingers_conn(left(1),left(2)) + ...
            fingers_conn(right(1),right(2));
        single_cell(row(j),col(j)) = counter > 0;
    end
    [dummy conn] = bwlabel(single_cell);
    numConn(i) = conn;
end
M = [M numConn'];
%figure, imshow(dummy), title('Last Connector');

%% measurements: fractal dimension
% cells_conn = bwperim(cells);
% for i=1:num
% 	single_cell = bwperim(L==i);
%     figure, boxcount(single_cell,'slope')
% end

