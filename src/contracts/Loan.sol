// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentLoanPlatform {
    struct Loan {
        address borrower;
        uint256 amount;
        uint256 interestRate;
        uint256 duration;
        uint256 startTime;
        uint256 endTime;
        uint256 totalRepayment;
        uint256 amountRepaid;
        address[] lenders;
        mapping(address => uint256) lenderContributions; // Lender contributions
        bool isFunded;
        bool isRepaid;
    }

    mapping(uint256 => Loan) public loans;
    mapping(address => uint256[]) public borrowerLoans;
    mapping(address => uint256[]) public lenderLoans;

    uint256 public loanCounter;
    uint256 public totalLendingPool;
    uint256 public interestRateBase = 3; // Example base interest rate (3%)

    event LoanRequested(uint256 loanId, address borrower, uint256 amount, uint256 interestRate, uint256 duration);
    event LoanFunded(uint256 loanId, address lender, uint256 amount);
    event LoanRepaid(uint256 loanId, uint256 amountRepaid);
    event LoanDefaulted(uint256 loanId);

    function requestLoan(uint256 amount, uint256 duration) external {
        require(amount > 0, "Loan amount must be greater than zero");
        require(duration > 0, "Loan duration must be greater than zero");

        uint256 interestRate = calculateInterestRate(duration);
        uint256 totalRepayment = amount + (amount * interestRate / 100);
        uint256 endTime = block.timestamp + duration;

        Loan storage newLoan = loans[loanCounter];
        newLoan.borrower = msg.sender;
        newLoan.amount = amount;
        newLoan.interestRate = interestRate;
        newLoan.duration = duration;
        newLoan.startTime = block.timestamp;
        newLoan.endTime = endTime;
        newLoan.totalRepayment = totalRepayment;

        borrowerLoans[msg.sender].push(loanCounter);

        emit LoanRequested(loanCounter, msg.sender, amount, interestRate, duration);

        loanCounter++;
    }

    function fundLoan(uint256 loanId) external payable {
        Loan storage loan = loans[loanId];
        require(loan.amount > 0, "Loan does not exist");
        require(!loan.isFunded, "Loan is already funded");
        require(msg.value == loan.amount, "Incorrect funding amount");

        loan.lenders.push(msg.sender);
        loan.lenderContributions[msg.sender] = msg.value;
        loan.isFunded = true;
        totalLendingPool += msg.value;
        lenderLoans[msg.sender].push(loanId);

        emit LoanFunded(loanId, msg.sender, msg.value);
    }

    function repayLoan(uint256 loanId) external payable {
        Loan storage loan = loans[loanId];
        require(loan.isFunded, "Loan is not funded");
        require(msg.sender == loan.borrower, "Only the borrower can repay the loan");
        require(!loan.isRepaid, "Loan is already repaid");
        require(block.timestamp <= loan.endTime, "Loan repayment period has expired");

        uint256 remainingRepayment = loan.totalRepayment - loan.amountRepaid;
        require(msg.value <= remainingRepayment, "Overpayment not allowed");

        loan.amountRepaid += msg.value;

        if (loan.amountRepaid >= loan.totalRepayment) {
            loan.isRepaid = true;
            emit LoanRepaid(loanId, loan.amountRepaid);
        }
    }

    function calculateInterestRate(uint256 duration) internal view returns (uint256) {
        // Simple interest rate calculation based on the base rate and duration
        return interestRateBase + (duration / 365 days);
    }

    function checkLoanDefault(uint256 loanId) external {
        Loan storage loan = loans[loanId];
        require(loan.isFunded, "Loan is not funded");
        require(block.timestamp > loan.endTime, "Loan repayment period has not expired");

        if (!loan.isRepaid) {
            emit LoanDefaulted(loanId);
        }
    }

    function withdrawFunds(uint256 loanId) external {
        Loan storage loan = loans[loanId];
        require(loan.isRepaid, "Loan is not repaid");

        uint256 amountToWithdraw = loan.lenderContributions[msg.sender];

        require(amountToWithdraw > 0, "No funds to withdraw");

        loan.lenderContributions[msg.sender] = 0;
        payable(msg.sender).transfer(amountToWithdraw);
    }
}
