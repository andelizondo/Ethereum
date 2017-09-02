pragma solidity ^0.4.15;

import './CrowdsaleToken.sol';
import './RefundableCrowdsale.sol';
import './Disposable.sol';

contract IterCrowdsale is Crowdsale, Refundable, Disposable {
	// Basic Crowdsale Properties
    uint256 _startTime = now;
    uint256 _endTime = now + 5 * 1 minutes;
    address _wallet = msg.sender;
    //address _token = 0x012cd5AD35e3051Cdb18a7F28c624D2D676b2425;
    CrowdsaleToken _token = new CrowdsaleToken();

	// Refundable Crowdsale Properties
	uint256 private _fundingGoal = 21;

	/* Initializes contract with its initial Basic and Tradeable properties */
	function IterCrowdsale(
	) Crowdsale (
        _startTime, _endTime, _wallet, _token
    ) Refundable (
		_fundingGoal
	) {}

	// overriding the original method to bypass ownership check and save gas on creation.
    function _setTokenContract(address _tokenAddress) internal {
        crowdsaleToken = CrowdsaleToken(_tokenAddress);    // Opens a previously created crowdsale token
    }

    // Overriding the basic function to give change when buying tokens
    function _buy(address _to, uint256 _value) internal {
        uint256 tokenAmount = crowdsaleToken.amountOfTokensToBuy(_value);       // calculate token amount to be created
        crowdsaleToken.mint(_to, tokenAmount);

        var tokenValue = crowdsaleToken.valueOfTokensToSell(tokenAmount);
        var change = msg.value - tokenValue;
		msg.sender.transfer(change);     					// returns change to the sender.

        // update state
        amountRaised += tokenValue;
        forwardFunds(tokenValue);							// Stores in the vault only the value of the purchased tokens
        TokenPurchase(msg.sender, _to, tokenValue, tokenAmount);
    }

	// Custom disposing method (Token -> Vault -> Crowdsale)
	function dispose() onlyOwner {
	    if (crowdsaleToken.owner() != 0 && crowdsaleToken.owner() == address(this)) {
	        crowdsaleToken.dispose();
	    }
	    if (vault.owner() != 0 && vault.owner() == address(this)) {
	        vault.dispose();
	    }
	    super.dispose();
	}
}
