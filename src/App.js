import React, { useState, useEffect } from 'react';
import Web3 from 'web3';
import abi from './abi.json';  // Import the ABI JSON
import './App.css';  // Import the CSS

function App() {
  const [loanAmount, setLoanAmount] = useState('');
  const [loanDuration, setLoanDuration] = useState('');
  const [loanId, setLoanId] = useState('');
  const [message, setMessage] = useState('');
  const [account, setAccount] = useState('');
  
  const contractAddress = '0xA2803f991862Ca894f12de74342370A95Ca0625F';  // Replace with your deployed contract address

  useEffect(() => {
    loadWeb3();
  }, []);

  const loadWeb3 = async () => {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
      const accounts = await window.web3.eth.getAccounts();
      setAccount(accounts[0]);
    } else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider);
    } else {
      setMessage('Non-Ethereum browser detected. You should consider trying MetaMask!');
    }
  };

  const requestLoan = async () => {
    try {
      const web3 = window.web3;
      const contract = new web3.eth.Contract(abi, contractAddress);
      const amountInWei = web3.utils.toWei(loanAmount, 'ether');

      await contract.methods.requestLoan(amountInWei, loanDuration).send({ from: account });
      setMessage('Loan requested successfully');
    } catch (error) {
      console.error(error);
      setMessage('Error requesting loan');
    }
  };

  const fundLoan = async () => {
    try {
      const web3 = window.web3;
      const contract = new web3.eth.Contract(abi, contractAddress);
      const amountInWei = web3.utils.toWei(loanAmount, 'ether');

      await contract.methods.fundLoan(loanId).send({ from: account, value: amountInWei });
      setMessage('Loan funded successfully');
    } catch (error) {
      console.error(error);
      setMessage('Error funding loan');
    }
  };

  const repayLoan = async () => {
    try {
      const web3 = window.web3;
      const contract = new web3.eth.Contract(abi, contractAddress);
      const amountInWei = web3.utils.toWei(loanAmount, 'ether');

      await contract.methods.repayLoan(loanId).send({ from: account, value: amountInWei });
      setMessage('Loan repaid successfully');
    } catch (error) {
      console.error(error);
      setMessage('Error repaying loan');
    }
  };

  return (
    <div className="App">
      <h1>Student Loan Platform</h1>
      <div className="form-group">
        <input
          type="text"
          placeholder="Loan Amount in ETH"
          value={loanAmount}
          onChange={(e) => setLoanAmount(e.target.value)}
        />
        <input
          type="text"
          placeholder="Loan Duration in seconds"
          value={loanDuration}
          onChange={(e) => setLoanDuration(e.target.value)}
        />
        <button onClick={requestLoan}>Request Loan</button>
      </div>
      <div className="form-group">
        <input
          type="text"
          placeholder="Loan ID"
          value={loanId}
          onChange={(e) => setLoanId(e.target.value)}
        />
        <button onClick={fundLoan}>Fund Loan</button>
        <button onClick={repayLoan}>Repay Loan</button>
      </div>
      <p>{message}</p>
    </div>
  );
}

export default App;
