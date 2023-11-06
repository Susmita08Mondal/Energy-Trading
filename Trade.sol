// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnergyTrading {

    // Define the structure for a trade
    struct Trade {
        address payable buyer;
        address payable seller;
        uint256 energyAmount;
        uint256 price;
        bool isCompleted;
    }

    // Store all trades in an array
    Trade[] public trades;

    // Event to notify when a trade is completed
    event TradeCompleted(address indexed buyer, address indexed seller, uint256 energyAmount, uint256 price);

    function initiateTrade(address _seller, uint256 _energyAmount, uint256 _price) public {
    // Ensure the trade has valid parameters
    require(_seller != msg.sender, "You Cannot Trade With Yourself");
    require(_energyAmount > 0, "Energy Amount Must Be Greater Than 0");
    require(_price > 0, "Price Must Be Greater Than 0");

    // Create a new trade object
    Trade memory newTrade = Trade({
        buyer: payable(msg.sender),
        seller: payable(_seller),
        energyAmount: _energyAmount,
        price: _price,
        isCompleted: false
    });

    // Add the trade to the array
    trades.push(newTrade);
}
    // Function for the seller to complete a trade
    function completeTrade(uint256 _tradeIndex) public {
        // Ensure the trade index is valid
        require(_tradeIndex < trades.length, "Invalid Trade Index");

        Trade storage trade = trades[_tradeIndex];

        // Ensure the sender is the seller and the trade is not already completed
        require(trade.seller == msg.sender, "You Are Not The Seller of This Trade");
        require(!trade.isCompleted, "Trade is Already Completed");

        // Transfer funds and energy
        uint256 totalPrice = trade.energyAmount * trade.price;
        payable(trade.seller).transfer(totalPrice);
        trade.buyer.transfer(trade.energyAmount);

        // Mark the trade as completed
        trade.isCompleted = true;

        // Emit an event to notify that the trade is completed
        emit TradeCompleted(trade.buyer, trade.seller, trade.energyAmount, trade.price);
    }
}