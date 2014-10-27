% Author: Stefanie Jegelka (stefje@eecs.berkeley.edu)

function [W, elist] = makeClGraph(n, degIn, degBet, nclust)
%
% makes nclust densely connected clusters (degIn-nearest neighbor graph), 
% and then connects them (degOut connections from each cluster)

doplot = 1;

npc = ceil(n/nclust);
n = npc*nclust;

W = zeros(n);

% TODO: SEEDING
%str1 = RandStream.create('m rg32k3a', 'Seed', seed, 'NumStreams',1);
%RandStream.setDefaultStream(str1);

for iC = 1:nclust
    % draw npc points uniformly
    pts = rand(3,npc);
    for iN = 1:npc
        ds = sum( (repmat(pts(:,iN),1,npc) - pts).^2, 1 );
        [dss, is] = sort(ds, 'ascend');
        W(iN + (iC-1)*npc,is(2:(degIn+1))+ (iC-1)*npc) = 1;        
    end
    
    if doplot
        ptsColl{iC} = pts;
    end
end
if npc < n
    for iC = 1:nclust    
        s = randi(npc, degBet, 1) + (iC-1)*npc;
        t = randi(n-npc, degBet, 1);
        cns = ceil(t/npc);
        cns(cns<iC) = 0;
        cns(cns>=iC) = 1;
        t = t + (cns)*npc;
        s = sub2ind([n,n], s, t);
        W(s) = 1;    
    end
end
W = max(W,W');
W = W - diag(diag(W));

elist = find(tril(W));
[elist(:,1), elist(:,2)] = ind2sub([n,n], elist);

if doplot
    adds = [0, 0; 1, 0; 0, 1; 1, 1; 2,0; 2,1; 2,2] * 3;
    figure;
    for iC = 1:nclust
        plot(ptsColl{iC}(1,:) + adds(iC,1), ptsColl{iC}(2,:) + adds(iC,2), 'k.','MarkerSize',15);
        hold on;                
    end
    cs = ceil(elist/npc);
    for iE = 1:length(elist)
        pt1 = ptsColl{cs(iE,1)}(1:2,mod(elist(iE,1), npc)+1) + adds(cs(iE,1),:)';
        pt2 = ptsColl{cs(iE,2)}(1:2,mod(elist(iE,2), npc)+1) + adds(cs(iE,2),:)';
        plot([pt1(1), pt2(1)], [pt1(2), pt2(2)], 'k');
    end
    hold off;    
end

