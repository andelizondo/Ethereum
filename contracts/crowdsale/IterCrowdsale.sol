pragma solidity ^0.4.15;

import './CrowdsaleToken.sol';
import './RefundableCrowdsale.sol';
import './Disposable.sol';

contract IterCrowdsale is Crowdsale, Refundable, Disposable {
	// Basic Crowdsale Properties
    uint256 _startTime = now;
    uint256 _endTime = now + 12 * 1 minutes;
    address _wallet = msg.sender;
    //address _token = 0xccfC733783A54aeC7F2d654011F9D7ce41ef395c;
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

	// Overriding this method to have crowdsale of the previously created token.
    function _setTokenContract(address _tokenAddress) internal {
        crowdsaleToken = _token;
    }

    // Overriding the function that calculates the crowdsale token price
    function _getTokenAmount(uint256 _ethAmount) internal constant returns (uint256) {
        return (_ethAmount * (10 ** uint256(crowdsaleToken.decimals()))) / crowdsaleToken.tokenPriceInWei();
    }

	// TODO: Improve disposing methods (Token -> Vault -> Crowdsale)
	function dispose() onlyOwner {
	    if (crowdsaleToken.owner() != 0 && crowdsaleToken.owner() == address(this)) {
	        crowdsaleToken.dispose();
	    }
	    if (vault.owner() != 0) {
	        vault.dispose();
	    }
	    super.dispose();
	}
}
