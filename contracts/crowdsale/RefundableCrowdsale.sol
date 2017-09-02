pragma solidity ^0.4.15;

import './ClosableCrowdsale.sol';
import './CrowdsaleVault.sol';

/**
 * @title RefundableCrowdsale
 * @dev Extension of Crowdsale contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
contract Refundable is Closable {
    // minimum amount of funds to be raised in weis
    uint256 public fundingGoal;

    // refund vault used to hold funds while crowdsale is running
    CrowdsaleVault public vault;

    function Refundable(uint256 _fundingGoal) {
        require(_fundingGoal > 0);
        vault = new CrowdsaleVault(msg.sender);
        fundingGoal = _fundingGoal * 1 ether;
    }

    // We're overriding the fund forwarding from Basic Crowdsale.
    // In addition to sending the funds, we want to call
    // the RefundVault deposit function
    function forwardFunds() internal {
        vault.deposit.value(msg.value)(msg.sender);
    }

    // if crowdsale is unsuccessful, investors can claim refunds here
    function claimRefund() {
        require(isClosed);
        require(!goalReached());
        vault.refund(msg.sender);
    }

    // vault finalization task, called when owner calls finalize()
    function _close() internal {
        if (goalReached()) {
            vault.withdraw();
        } else {
            vault.enableRefunds();
        }

        // If crowdsale is owner of token, give ownership back to the crowdsale creator
        if (crowdsaleToken.owner() == address(this)) {
            crowdsaleToken.transferOwnership(owner);
        }
    }

    function goalReached() public constant returns (bool) {
        return amountRaised >= fundingGoal;
    }
}
