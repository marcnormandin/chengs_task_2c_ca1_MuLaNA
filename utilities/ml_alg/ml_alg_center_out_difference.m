function [angleDiff_deg] =  ml_alg_center_out_difference(coa1_deg, coa2_deg)
    % Compute the angle difference. How much we have to rotate the second map
    % counter clockwise (in image coordinates) to align with the first map.
    aunit = [cosd(coa1_deg), sind(coa1_deg)];
    bunit = [cosd(coa2_deg), sind(coa2_deg)];
    cross21 = cross([bunit(1), bunit(2), 0], [aunit(1), aunit(2), 0]); % b x a
    interiorAngle = real(acosd( dot(aunit, bunit) ));
    exteriorAngle = real(360 - interiorAngle);
    if cross21(3) > 0
        angleDiff_deg = interiorAngle;
    else
        angleDiff_deg = exteriorAngle;
    end
end % function
