// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Graph {
    struct Node {
        uint256 id;
        string data;
        uint256[] links;
    }

    mapping(uint256 => Node) private nodes;
    uint256 private nextNodeId;

    event NodeCreated(uint256 indexed nodeId, string data);
    event NodeUpdated(uint256 indexed nodeId, string data);
    event LinkCreated(uint256 indexed fromNodeId, uint256 indexed toNodeId);

    function createNode(string memory data) public returns (uint256) {
        uint256 nodeId = nextNodeId++;
        nodes[nodeId] = Node({
            id: nodeId,
            data: data,
            links: new uint256[](0)
        });
        emit NodeCreated(nodeId, data);
        return nodeId;
    }

    function updateNode(uint256 nodeId, string memory data) public {
        require(nodeId < nextNodeId, "Node does not exist");
        nodes[nodeId].data = data;
        emit NodeUpdated(nodeId, data);
    }

    function createLink(uint256 fromNodeId, uint256 toNodeId) public {
        require(fromNodeId < nextNodeId && toNodeId < nextNodeId, "Node does not exist");
        nodes[fromNodeId].links.push(toNodeId);
        emit LinkCreated(fromNodeId, toNodeId);
    }

    function getNode(uint256 nodeId) public view returns (uint256, string memory, uint256[] memory) {
        require(nodeId < nextNodeId, "Node does not exist");
        Node storage node = nodes[nodeId];
        return (node.id, node.data, node.links);
    }

    function getLinkCount(uint256 nodeId) public view returns (uint256) {
        require(nodeId < nextNodeId, "Node does not exist");
        return nodes[nodeId].links.length;
    }
}