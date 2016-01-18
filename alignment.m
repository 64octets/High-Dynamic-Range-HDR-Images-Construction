function [image2_aligned shift] = alignment(image1, image2)
H = size(image1, 1);
W = size(image1, 2);
image1_gray = rgb2gray(image1);
image2_gray = rgb2gray(image2);
% MTB
noiseThreshold = 1;
median1 = median(double(image1_gray(:)));
median2 = median(double(image2_gray(:)));
image1_MTB = (image1_gray >= median1); %�p�G�j��threshold�A�O1
image2_MTB = (image2_gray >= median2);
% exclusion map
image1_eMap = (abs(image1_gray-median1) >= noiseThreshold);
image2_eMap = (abs(image2_gray-median2) >= noiseThreshold);
eMap = image1_eMap&image2_eMap; % exclusion map

% Find Offset   (����image2�ӦXimage1)
%���Ⲿ�����ϫئn
%�A��XOR, AND����� (�@������9��neighbor)
%�b�D�̦n��
max_scale_power = 0; %�Ϸ|�Q�Y��̤p����ҡG2^max_scale_power
shift = [0, 0]; %�|�@���Q��s�A�̲�image2�n�����B�� [y, x]

for scale_power = max_scale_power:-1:0
    scale = 2^(scale_power);
    image1_MTB_scale = imresize(image1_MTB, 1/scale, 'bilinear');
    image2_MTB_scale = imresize(image2_MTB, 1/scale, 'bilinear');
    eMap_scale = imresize(eMap, 1/scale, 'bilinear'); %�i�H�ոլݥ�scale�Mshift���A����exclusion map
    H_scale = size(image1_MTB_scale, 1);
    W_scale = size(image1_MTB_scale, 2);
 
    image2_MTB_scale_shift = image2_MTB_scale; % image2_MTB_scale_shift�O�o�@��scale level�����(�nshift�h�֤w�g�Q���e��p���h�M�w)
    shift_scale = round(shift*1/scale);   
    %��W�@�h�M�w�n�����B�ơA�������ϫئn
    for i = 1 : H_scale
        for j = 1 : W_scale
           if ( ((j+shift_scale(2))<1 ) || ((j+shift_scale(2))>W_scale) || ((i+shift_scale(1))<1) || ((i+shift_scale(1))>H_scale) )
               image2_MTB_scale_shift(i,j) = 0;
           else
               image2_MTB_scale_shift(i,j) = image2_MTB_scale(i+shift_scale(1),j+shift_scale(2));
           end                          
        end
    end
    
    %�P�_���L��image2�٭n���h��
    shift_ = [0, 0];
    minimum = H*W;
    temp_image2_MTB_scale_shift = image2_MTB_scale_shift;
    for dy = -1:1 %(-1, 0, 1)
        for dx = -1:1
            %�Ⲿ�����ϫئn
            for i = 1 : H_scale 
                for j = 1 : W_scale
                    if ( ((j+shift_scale(2)+dx)<1 ) || ((j+shift_scale(2)+dx)>W_scale) || ((i+shift_scale(1)+dy)<1) || ((i+shift_scale(1)+dy)>H_scale) )
                        temp_image2_MTB_scale_shift(i,j) = 0;
                    else
                        temp_image2_MTB_scale_shift(i,j) = image2_MTB_scale(i+shift_scale(1)+dy,j+shift_scale(2)+dx);
                    end
                end
            end
            diff = sum(sum(eMap_scale & xor(image1_MTB_scale, temp_image2_MTB_scale_shift)));
            if (diff < minimum)
                shift_ = [dy, dx];
                minimum = diff;
            end
        end
    end
    
    %��sshift
    shift(1) = shift(1) + shift_(1)*scale;
    shift(2) = shift(2) + shift_(2)*scale;
end


%��image2
image2_aligned = zeros(H, W, 3);
for i = 1 : H
    for j = 1 : W
        if ( ((j+shift(2))<1 ) || ((j+shift(2))>W_scale) || ((i+shift(1))<1) || ((i+shift(1))>H_scale) )
            image2_aligned(i, j, 1) = 0;
			image2_aligned(i, j, 2) = 0;
			image2_aligned(i, j, 3) = 0;
        else
            image2_aligned(i, j, 1) = image2(i+shift(1),j+shift(2), 1);
			image2_aligned(i, j, 2) = image2(i+shift(1),j+shift(2), 2);
			image2_aligned(i, j, 3) = image2(i+shift(1),j+shift(2), 3);
        end
    end
end