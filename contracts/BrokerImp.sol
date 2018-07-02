pragma solidity ^0.4.21;

import "./ownership/MultiOwnable.sol";
import "./math/SafeMath.sol";
import "./util/DestroyableMultiOwner.sol";

interface Token {
	function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}

contract BrokerImp is DestroyableMultiOwner {
	using SafeMath for uint256;
	
	Token public token;
	uint256 public commission;
	address public broker;
	address public pool;
	uint256 public ethReward;
	mapping(address => bool) public ethSent;
	
	event CommissionChanged(uint256 _previousCommission, uint256 _commision);
	event EthRewardChanged(uint256 _previousEthReward, uint256 _ethReward);
	event BrokerChanged(address _previousBroker, address _broker);
	event PoolChanged(address _previousPool, address _pool);
	
	/**
	 * @dev Constructor.
	 * @param _token The token address
	 * @param _pool The pool of tokens address
	 * @param _commission The percentage of the commission 0-100
	 * @param _broker The broker address
	 * @param _ethReward The eth to send to the beneficiary of the reward only once in wei
	 */
	constructor (address _token, address _pool, uint256 _commission, address _broker, uint256 _ethReward) public {
		require(_token != address(0));
		token = Token(_token);
		pool = _pool;
		commission = _commission;
		broker = _broker;
		ethReward = _ethReward;
	}
	
	/**
	 * @dev Allows to fund the contract with ETH.
	 */
	function fund(uint256 amount) payable public {
		require(msg.value == amount);
	}
	
	/**
	 * @dev Allows the owner make a reward.
	 * @param _beneficiary the beneficiary address
	 * @param _value the tokens reward in wei
	 */
	function reward(address _beneficiary, uint256 _value) public onlyOwner returns (bool) {
		uint256 hundred = uint256(100);
		uint256 beneficiaryPart = hundred.sub(commission);
		uint256 total = (_value.div(beneficiaryPart)).mul(hundred);
		uint256 brokerCommission = total.sub(_value);
		if (!ethSent[_beneficiary]) {
			_beneficiary.transfer(ethReward);
			ethSent[_beneficiary] = true;
		}
		return (
		token.transferFrom(pool, broker, brokerCommission) &&
		token.transferFrom(pool, _beneficiary, _value)
		);
	}
	
	/**
	 * @dev Allows the owner to change the commission of the reward.
	 * @param _commission The percentage of the commission 0-100
	 */
	function changeCommission(uint256 _commission) public onlyOwner {
		emit CommissionChanged(commission, _commission);
		commission = _commission;
	}
	
	/**
	 * @dev Allows the owner to withdraw the balance of the tokens.
	 * @param _ethReward The eth reward to send to the beneficiary in wei
	 */
	function changeEthReward(uint256 _ethReward) public onlyOwner {
		emit EthRewardChanged(ethReward, _ethReward);
		ethReward = _ethReward;
	}
	
	/**
	 * @dev Allows the owner to change the broker.
	 * @param _broker The broker address
	 */
	function changeBroker(address _broker) public onlyOwner {
		emit BrokerChanged(broker, _broker);
		broker = _broker;
	}
	
	/**
	 * @dev Allows the owner to change the pool of tokens.
	 * @param _pool The pool address
	 */
	function changePool(address _pool) public onlyOwner {
		emit PoolChanged(pool, _pool);
		pool = _pool;
	}
}
