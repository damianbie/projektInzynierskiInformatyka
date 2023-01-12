function [img] = insertImageInPos(im1, im2, al2, posX, posY)
    img = im1;
    im2Size = size(im2);
    im1Size = size(im1);

    if(posX + im2Size(1) > im1Size(1) || posY + im2Size(2) > im1Size(2))
        fprintf("Error | Obrazy maja zle wielkosci!!\n");
        return;
    end

    for iX = 1 : im2Size(1)
        for iY = 1 : im2Size(2)
            if al2(iX, iY) > 50
                img(iX + posX, iY + posY, :) = im2(iX, iY, :);
            end
        end
    end
end