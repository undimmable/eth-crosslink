// Пример взаимодействия с контрактом на JavaScript с использованием web3.js

const Web3 = require('web3');
const web3 = new Web3('https://ropsten.infura.io/v3/YOUR_INFURA_PROJECT_ID');

const contractAddress = '0xYourContractAddress';
const abi = [ /* ABI контракта */ ];

const contract = new web3.eth.Contract(abi, contractAddress);
const account = '0xYourAccountAddress';
const privateKey = '0xYourPrivateKey';

// Добавление новой кроссссылки
async function addLink(nodeId, blockchainName, link) {
    const data = contract.methods.addCrossLink(nodeId, blockchainName, link).encodeABI();

    const tx = {
        to: contractAddress,
        data,
        gas: 2000000
    };

    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);
    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log('Transaction receipt:', receipt);
}

// Изменение существующей кроссссылки
async function updateLink(nodeId, linkIndex, blockchainName, link) {
    const data = contract.methods.updateCrossLink(nodeId, linkIndex, blockchainName, link).encodeABI();

    const tx = {
        to: contractAddress,
        data,
        gas: 2000000
    };

    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);
    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log('Transaction receipt:', receipt);
}

// Пример вызова функций
addLink(1, 'Ethereum', 'https://etherscan.io/block/123456');
updateLink(1, 0, 'Ethereum', 'https://etherscan.io/block/654321');