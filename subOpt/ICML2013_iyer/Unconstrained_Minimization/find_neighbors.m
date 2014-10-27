function B = find_neighbors(G, A, covered)
    B = [];
    [~, n] = size(G);
    for i = 1 : length(A)
        B = [B, covered{A(i)}];
    end
    B = sfo_unique_fast(B);
end
