function [sp, splist, spcost] = shortest_path(A, s, d)
% This is an implementation of the dijkstras algorithm, wich finds the 
% minimal cost path between two nodes. 

% the inputs of the algorithm are:
% n: the number of nodes in the network;
% s: source node index;
% d: destination node index;

%For information about this algorithm visit:
%http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
A = 100000*(A == 0) + A;                    % Give very high cost to the non-existent edges
n=size(A,1);
S(1:n) = 0;     %s, vector, set of visited vectors
dist(1:n) = inf;   % it stores the shortest distance between the source node and any other node;
prev(1:n) = n+1;    % Previous node, informs about the best previous node known to reach each  network node 

dist(s) = 0;


while sum(S)~=n
    candidate=[];
    for i=1:n
        if S(i)==0
            candidate=[candidate, dist(i)];
        else
            candidate=[candidate, inf];
        end
    end
    [u_index u]=min(candidate);
    S(u)=1;
    for i=1:n
        if(dist(u)+A(u,i))<dist(i)
            dist(i)=dist(u)+A(u,i);
            prev(i)=u;
        end
    end
end


sp = [d];
splist = [];
while sp(1) ~= s
    if prev(sp(1))<=n
        splist = [splist; [prev(sp(1)), sp(1)]];
        sp=[prev(sp(1)) sp];
    else
        error;
    end
end;
spcost = dist(d);