pragma solidity ^0.4.13;

contract CrowdsaleToken {
	address public owner;
	uint8 public decimals;
	uint256 public tokenPrice;
	uint256 public etherPrice;
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

contract Crowdsale {
    // Basic Properties of the Crowdsale
    address public beneficiary;
    uint256 public fundingGoal;
    uint256 public amountRaised;

    // Start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    CrowdsaleToken public crowdsaleToken;
    mapping(address => uint256) public balanceOf;

    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;

    event FundTransfer(address _backer, uint _amount, bool _isContribution);
    event CrowdsaleClose(address _beneficiary, uint _amountRaised, bool _fundingGoalReached);

    /* data structure to hold information about campaign contributors */

    /*  at initialization, setup the owner */
    function Crowdsale() {
        beneficiary = msg.sender;                   // Sets the beneficiary to the contract creator
        fundingGoal = 21 * 1 ether;
        startTime = now;
        endTime = now + 12 * 1 minutes;
        crowdsaleToken = CrowdsaleToken(0x7eD7AF0bf29f64b12A4aB57c34642763a47218BD);
    }

    modifier afterDeadline() { require (now >= endTime); _; }

    /* The function without name is the default function that is called whenever anyone sends funds to a contract */
    function () payable {
        buyTokens(msg.sender);
    }
    function buyTokens(address beneficiary) payable {
        require(beneficiary != 0x0);
        require(validPurchase());
        uint256 amount = msg.value;

        // Token Amount calculated by current Token/Eth Price
        var tokenAmount = (amount * (10 ** uint256(crowdsaleToken.decimals())))
            / (1 ether * crowdsaleToken.tokenPrice() / crowdsaleToken.etherPrice());

        crowdsaleToken.transferFrom(crowdsaleToken.owner(), msg.sender, tokenAmount);

        // Crowdfunding details updated
        _depositFunds(amount);
    }

    function withdrawFunds() afterDeadline {
        if (!fundingGoalReached) {
            uint256 amount = balanceOf[msg.sender];
            require (amount > 0);
            balanceOf[msg.sender] = 0;
            if (msg.sender.send(amount)) {
                _withdrawFunds(amount);
            } else {
                balanceOf[msg.sender] = amount;
            }
        }
        else if (beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                _withdrawFunds(amountRaised);
            } else {
                //If we fail to send the funds to beneficiary, unlock funders balance
                fundingGoalReached = false;
            }
        }
    }

    function _depositFunds(uint256 _value) internal {
        balanceOf[msg.sender] += _value;
        amountRaised += _value;
        if (amountRaised >= fundingGoal) {
            fundingGoalReached = true;
        }
        FundTransfer(msg.sender, _value, true);
    }
    function _withdrawFunds(uint256 _value) internal {
        amountRaised -= _value;
        if (amountRaised == 0) {
            crowdsaleClosed = true;
        }
        FundTransfer(msg.sender, _value, false);
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
      wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }
    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        return now > deadline;
    }

    // ONLY for testing purposes
    function kill() {
		selfdestruct(beneficiary);
	}
}
