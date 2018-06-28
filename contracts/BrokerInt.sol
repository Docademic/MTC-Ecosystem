pragma solidity ^0.4.21;

import "./ownership/MultiOwnable.sol";
import "./math/SafeMath.sol";
import "./util/Destroyable.sol";

interface BrokerImp {
	function reward(address _beneficiary, uint256 _value) external returns (bool);
}

contract BrokerInt is MultiOwnable, Destroyable {
	using SafeMath for uint256;
	
	BrokerImp public brokerImp;
	
	event BrokerImpChanged(address _previousBrokerImp, address _brokerImp);
	event Reward(address _to, uint256 _value);
	
	/**
	 * @dev Constructor.
	 * @param _brokerImp the broker implementation address
	 */
	constructor(address _brokerImp) public{
		require(_brokerImp != address(0));
		brokerImp = BrokerImp(_brokerImp);
	}
	
	/**
	 * @dev Allows the owner make a reward.
	 * @param _beneficiary the beneficiary address
	 * @param _value the tokens reward in wei
	 */
	function reward(address _beneficiary, uint256 _value) public onlyOwner {
		require(brokerImp.reward(_beneficiary, _value));
		emit Reward(_beneficiary, _value);
	}
	
	/**
	 * @dev Allows the owner to change the brokerImp.
	 * @param _brokerImp The brokerImp address
	 */
	function changeBrokerImp(address _brokerImp) public onlyOwner {
		emit BrokerImpChanged(brokerImp, _brokerImp);
		brokerImp = BrokerImp(_brokerImp);
	}
}
