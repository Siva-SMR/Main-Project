% Define network parameters
numNodes = 10;
maxRange = 50;
txPower = 10;
rxSensitivity = -80;

% Create network topology
positions = maxRange*rand(numNodes, 2);
connections = zeros(numNodes);
for i = 1:numNodes
    for j = i+1:numNodes
        distance = norm(positions(i,:) - positions(j,:));
        if distance <= maxRange
            pathLoss = (4*pi*distance*2.4e9/3e8)^2;
            gain = sqrt(txPower/pathLoss);
            connections(i,j) = gain;
            connections(j,i) = gain;
        end
    end
end

% Initialize network node objects
for i = 1:numNodes
    nodes(i).txSuccess = 0;
    nodes(i).txFailure = 0;
end

% Simulate network
simTime = 10; % Define simulation time
for t = 1:simTime
    for i = 1:numNodes
        receivedPower = 0;
        for j = 1:numNodes
            if connections(i,j) ~= 0
                receivedPower = receivedPower + connections(i,j)^2*txPower;
            end
        end
        if receivedPower >= 10^(rxSensitivity/10)
            nodes(i).txSuccess = nodes(i).txSuccess + 1;
        else
            nodes(i).txFailure = nodes(i).txFailure + 1;
        end
    end
end

% Analyze network performance
throughput = getThroughput(nodes, simTime);
delay = getDelay(nodes, simTime);
packetLoss = getPacketLoss(nodes, simTime);

% Define performance metrics functions
function throughput = getThroughput(nodes, simTime)
    totalSuccess = 0;
    for i = 1:length(nodes)
        totalSuccess = totalSuccess + nodes(i).txSuccess;
    end
    totalTime = length(nodes)*simTime;
    throughput = totalSuccess/totalTime;
end

function delay = getDelay(nodes, simTime)
    totalDelay = 0;
    totalPackets = 0;
    for i = 1:length(nodes)
        totalDelay = totalDelay + nodes(i).txSuccess;
        totalPackets = totalPackets + nodes(i).txSuccess + nodes(i).txFailure;
    end
    delay = totalDelay/totalPackets;
end

function packetLoss = getPacketLoss(nodes, simTime)
    totalFailure = 0;
    for i = 1:length(nodes)
        totalFailure = totalFailure + nodes(i).txFailure;
    end
    totalPackets = length(nodes)*simTime;
    packetLoss = totalFailure/totalPackets;
end
