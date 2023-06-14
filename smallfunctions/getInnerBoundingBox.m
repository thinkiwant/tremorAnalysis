function [child_outer_BB] = getInnerBoundingBox(parentBB, child_inner_BB)

if length(parentBB) ~= 4
    error("invalid parent bounding box parameters\n");
elseif length(child_inner_BB) ~= 4
    error("invalid in child bounding box parameters\n");
end

child_outer_BB = zeros(4, 1);
child_outer_BB(1) = parentBB(1) + child_inner_BB(1)*parentBB(3);
child_outer_BB(2) = parentBB(2) + child_inner_BB(2)*parentBB(4);
child_outer_BB(3) = parentBB(3) * child_inner_BB(3);
child_outer_BB(4) = parentBB(4) * child_inner_BB(4);

end