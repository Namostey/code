// contractInteraction.js
import Web3 from 'web3';
import LaunchPadABI from './abi.json';

const contractAddress = '0xC8CF29d9D1595a3588AD36E6349A0E9a5b632720'; // Replace with your deployed contract address

const getWeb3 = () => {
    return new Promise((resolve, reject) => {
        window.addEventListener('load', async () => {
            if (window.ethereum) {
                const web3 = new Web3(window.ethereum);
                try {
                    await window.ethereum.enable();
                    resolve(web3);
                } catch (error) {
                    reject(error);
                }
            } else if (window.web3) {
                resolve(new Web3(window.web3.currentProvider));
            } else {
                reject('No Web3 provider found. Install Metamask.');
            }
        });
    });
};

const getContract = async () => {
    const web3 = await getWeb3();
    return new web3.eth.Contract(LaunchPadABI, contractAddress);
};

export { getWeb3, getContract };
