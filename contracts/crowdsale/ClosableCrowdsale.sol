pragma solidity ^0.4.15;

import './BasicCrowdsale.sol';
import './Ownable.sol';

/**
* @title ClosableCrowdsale
* @dev Extension of Crowsdale where an owner can do extra work
* after the crowdsale has ended.
*/
contract Closable is Crowdsale, Ownable {
    bool public isClosed = false;

    event CrowdsaleClosed(address indexed _owner);

    /**
    * @dev Must be called after crowdsale ends, to do some extra closure
    * work. Calls the contract's closure function.
    */
    function close() onlyOwner {
        require(!isClosed);
        require(hasEnded());

        _close();

        isClosed = true;
        CrowdsaleClosed(owner);
    }

    /**
    * @dev Abstract method to add closure logic.
    */
    function _close() internal;
}
