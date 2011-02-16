function borders=gpb_gpu(image)
    imsize=size(image);
    if ndims(image)~=3
        disp('Error: only color images supported');
        return;
    elseif imsize(3)~=3
        disp('Error: Need rgb-channels');
        return;
    end
    padded=zeros(imsize(1),imsize(2),4);
    padded(:,:,1:3)=image;
    padded=permute(uint8(padded),[3,2,1]); % interleaved row major
    borders=gpb_mex(padded);
    borders=borders';
end