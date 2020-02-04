function [B, offset] = fEgalisateur(lum, contrast, lumref, contrastref)

if contrast,
    B = contrastref./contrast;
    offset = lumref - B .* lum;
else
    B = 0;
    offset = lumref;
end
    

