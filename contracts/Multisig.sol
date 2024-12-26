// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    address[] public owners;
    uint256 public required;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    uint256 public transactionCount;

    event Deposit(address indexed sender, uint256 value);
    event Submission(uint256 indexed transactionId);
    event Confirmation(address indexed owner, uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Not owner");
        _;
    }

    modifier transactionExists(uint256 transactionId) {
        require(transactions[transactionId].to != address(0), "Transaction does not exist");
        _;
    }

    modifier confirmed(uint256 transactionId, address owner) {
        require(confirmations[transactionId][owner], "Transaction not confirmed");
        _;
    }

    modifier notConfirmed(uint256 transactionId, address owner) {
        require(!confirmations[transactionId][owner], "Transaction already confirmed");
        _;
    }

    modifier notExecuted(uint256 transactionId) {
        require(!transactions[transactionId].executed, "Transaction already executed");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required number of confirmations");

        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            owners.push(_owners[i]);
        }

        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address to, uint256 value, bytes memory data) public onlyOwner returns (uint256) {
        uint256 transactionId = addTransaction(to, value, data);
        confirmTransaction(transactionId);
        return transactionId;
    }

    function confirmTransaction(uint256 transactionId) public onlyOwner transactionExists(transactionId) notConfirmed(transactionId, msg.sender) {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function executeTransaction(uint256 transactionId) public onlyOwner transactionExists(transactionId) notExecuted(transactionId) {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            (bool success, ) = txn.to.call{value: txn.value}(txn.data);
            if (success) {
                emit Execution(transactionId);
            } else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    function isConfirmed(uint256 transactionId) public view returns (bool) {
        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                count += 1;
            }
            if (count == required) {
                return true;
            }
        }
        return false;
    }

    function addTransaction(address to, uint256 value, bytes memory data) internal returns (uint256 transactionId) {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            to: to,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    function isOwner(address account) internal view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == account) {
                return true;
            }
        }
        return false;
    }
}