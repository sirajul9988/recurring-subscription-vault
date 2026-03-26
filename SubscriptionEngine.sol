// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SubscriptionEngine is ReentrancyGuard {
    struct Subscription {
        uint256 lastPaymentTimestamp;
        uint256 monthlyRate;
        bool isActive;
    }

    IERC20 public immutable paymentToken;
    uint256 public constant INTERVAL = 30 days;

    // creator => user => Subscription
    mapping(address => mapping(address => Subscription)) public subscriptions;

    event Subscribed(address indexed creator, address indexed user, uint256 rate);
    event PaymentCollected(address indexed creator, address indexed user, uint256 amount);
    event Unsubscribed(address indexed creator, address indexed user);

    constructor(address _paymentToken) {
        paymentToken = IERC20(_paymentToken);
    }

    /**
     * @dev User joins a creator's subscription plan.
     */
    function subscribe(address _creator, uint256 _rate) external {
        require(_rate > 0, "Rate must be positive");
        
        subscriptions[_creator][msg.sender] = Subscription({
            lastPaymentTimestamp: 0,
            monthlyRate: _rate,
            isActive: true
        });

        emit Subscribed(_creator, msg.sender, _rate);
    }

    /**
     * @dev Creator (or relayer) pulls the monthly fee.
     */
    function collectPayment(address _user) external nonReentrant {
        Subscription storage sub = subscriptions[msg.sender][_user];
        
        require(sub.isActive, "Subscription not active");
        require(
            block.timestamp >= sub.lastPaymentTimestamp + INTERVAL,
            "Payment not due yet"
        );

        sub.lastPaymentTimestamp = block.timestamp;

        bool success = paymentToken.transferFrom(_user, msg.sender, sub.monthlyRate);
        require(success, "Transfer failed - check allowance/balance");

        emit PaymentCollected(msg.sender, _user, sub.monthlyRate);
    }

    /**
     * @dev User cancels the subscription.
     */
    function unsubscribe(address _creator) external {
        subscriptions[_creator][msg.sender].isActive = false;
        emit Unsubscribed(_creator, msg.sender);
    }

    /**
     * @dev View function to check if a user is currently "In Good Standing".
     */
    function isValidSubscriber(address _creator, address _user) external view returns (bool) {
        Subscription memory sub = subscriptions[_creator][_user];
        if (!sub.isActive) return false;
        
        // Allow a 3-day grace period after the interval expires
        return block.timestamp <= sub.lastPaymentTimestamp + INTERVAL + 3 days;
    }
}
