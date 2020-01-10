function [FinalMovie] = improcess2D_dimmerCellsV2_mpc(FinalImage, steepness);
% load in the tiff stack images
% input: the tiff stack images; and the steepness of the intensity
% adjustment curve; 0.9 or 0.95 seems to be good
% output: processed output movie
% the analysis flow is: 
% 1) Remove background: morphological filtering -> imtophat (imopen
% followed by subtraction
% 2) Normalization: Contrast-stretching method works better in our dataset
% 3) run again the imtophat to remove the blurriness
% 2018/06/10 MPC

frames = length(FinalImage(1,1,:));
[row, col] = size(FinalImage(:,:,1));
FinalMovie = zeros(row,col,frames);

parfor i = 1:frames;
    % top-hat: the morphological opening of the image (using imopen) and then subtracts the result from the original image
    g_sub = imtophat(FinalImage(:,:,i), strel('disk', 30));
    g_sub = double(g_sub);
    
    %figure; imshow(g_sub, []);
    % Normalization
    g_norm = g_sub./max(g_sub(:));

    % use contrast-stretching method to normalize the intensity
    level = graythresh(g_norm);
    level2 = level*0.4; % 0.685 
    g_ad2 = 1./(1+(level2./(g_norm+eps)).^steepness);
    %figure; imshow(g_ad2, []);
    
    % try another run of image top-hat to remove the blurry background
    g_ad3 = imtophat(g_ad2, strel('disk', 30));
    
    level3 = graythresh(g_ad3);
    g_ad4 = imadjust(g_ad3, [level3*0.3 1]);
    
    FinalMovie(:,:,i) = g_ad4;
   
end


figure; 
subplot(1,2,1); imshow(FinalImage(:,:,1), []);
subplot(1,2,2); imshow(FinalMovie(:,:,1), []);



