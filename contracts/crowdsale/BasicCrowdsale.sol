pragma solidity ^0.4.15;

import './CrowdsaleToken.sol';

/**
* @title Crowdsale
* @dev Crowdsale is a base contract for managing a token crowdsale.
* Crowdsales have a start and end timestamps, where investors can make
* token purchases and the crowdsale will assign them tokens based
* on a token per ETH rate. Funds collected are forwarded to a wallet
* as they arrive.
*/
contract Crowdsale {
    // The token being sold
    CrowdsaleToken public crowdsaleToken;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    // uint256 public rate;

    // amount of raised money in wei
    uint256 public amountRaised;

    /**
    * event for token purchase logging
    * @param purchaser who paid for the tokens
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function Crowdsale(uint256 _startTime, uint256 _endTime, address _wallet, address _tokenAddress) {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_wallet != 0x0);

        crowdsaleToken = CrowdsaleToken(_tokenAddress);     // Opens the token previously created crowdsale token 
        require(crowdsaleToken.owner() == msg.sender);      // Checks that the crowdsale creator is the owner of the Token
        // crowdsaleToken.approveMintAgent(this, true);     // TODO: Approve this contract as Mint Agent

        startTime = _startTime;
        endTime = _endTime;
        wallet = _wallet;
    }

    // fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 amount = msg.value;

        // calculate token amount to be created
        uint256 tokenAmount = (amount * (10 ** uint256(crowdsaleToken.decimals()))) / crowdsaleToken.tokenPriceInWei();

        // update state
        amountRaised += amount;

        crowdsaleToken.mint(beneficiary, tokenAmount);
        TokenPurchase(msg.sender, beneficiary, amount, tokenAmount);

        forwardFunds();
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
        return now > endTime;
    }
}
