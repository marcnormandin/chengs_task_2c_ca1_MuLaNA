function [r] = ml_alg_image_align_B_to_A(A,B)
    % This will use maximum cross correlation to find the best
    % alignment of B relative to A.
    % The k1 vector can be used for coordinate transformations.
    
    padSize = max([size(A,1), size(A,2)]); % compute padding size

    IA = prepare_image(A, padSize);
    IB = prepare_image(B, padSize);

    cc = xcorr2(IB,IA);
    [max_cc, imax] = max(abs(cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset = [(ypeak-size(A,1)) (xpeak-size(A,2))];
    
    % Correct the offset we need
    k1 = -(2*padSize - corr_offset);

    % Extract a portion from B that is the same size as A
    E = IB(padSize+k1(1)+1:padSize+k1(1)+size(A,1), padSize+k1(2)+1:padSize+k1(2)+size(A,2));
    
    % From B coordinates to Template coordinates
    % P in Template = P in B - k1

    % Store
    r.max_cc = max_cc;
    r.k1 = k1; % This is the linear transformation to apply
    r.BAlignedToA = E;
end


function [IPadded] = prepare_image(I,padSize)
    % Add padding around the image
    IPadded = zeros( size(I,1)+2*padSize, size(I,2)+2*padSize);
    IPadded(padSize+1:padSize+size(I,1),padSize+1:padSize+size(I,2)) = I;
    
    IPadded = IPadded - mean(mean(IPadded));
    %IPadded = IPadded - mean(mean(I));
end
