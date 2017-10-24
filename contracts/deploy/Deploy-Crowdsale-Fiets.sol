pragma solidity ^0.4.15;

import './Crowdsale-Token.sol';
import './Crowdsale-Refundable.sol';
import './Utils-Disposable.sol';

contract CrowdsaleFiets is Crowdsale, Refundable, Disposable {
	// Basic Crowdsale Properties
    uint256 _startTime = now;
    uint256 _endTime = now + 5 * 1 minutes;
    address _wallet = msg.sender;

	// Crowdsale Token Properties
	// Basic Token Properties
	string private _version = '0.12';
	string private _name = 'Fiets';
	string private _symbol = hex"F09F9AB2";
	uint8  private _decimals = 0;
	uint256 private _totalSupply = 0;
	uint256 _tokenPrice = 210;
	uint256 _etherPrice = 270;
    CrowdsaleToken _token = new CrowdsaleToken(_version, _name, _symbol, _decimals, _totalSupply, _tokenPrice, _etherPrice);
    //address _token = 0x03d5cd402d6640792224da60997e931a70770ad5; // Use this line when token was previously created

	// Refundable Crowdsale Properties
	uint256 private _fundingGoal = 21;

	/* Initializes contract with its initial Basic and Tradeable properties */
	function CrowdsaleFiets(
	) Crowdsale (
        _startTime, _endTime, _wallet, _token
    ) Refundable (
		_fundingGoal
	) {}

    // USE WHEN CREATING NEW TOKEN
    // overriding the original method to bypass ownership check and save gas on creation.
    function _setTokenContract(address _tokenAddress) internal {
        crowdsaleToken = _token;
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
