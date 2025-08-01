// File: contracts/SupplyChain.sol
pragma solidity ^0.8.0;

contract SupplyChain {
    enum Role { None, Manufacturer, Retailer, Buyer }
    enum State { Created, AtRetailer, Sold }

    struct Product {
        uint id; 
        string name;
        address currentOwner;
        State state; 
        string[] history; 
    }

    uint public productCounter = 0;
    mapping(uint => Product) public products;
    mapping(address => Role) public roles;

    modifier onlyManufacturer() {
        require(roles[msg.sender] == Role.Manufacturer, "Only manufacturers allowed");
        _;
    }

    modifier onlyRetailer() {
        require(roles[msg.sender] == Role.Retailer, "Only retailers allowed");
        _;
    }

    modifier onlyBuyer() {
        require(roles[msg.sender] == Role.Buyer, "Only buyers allowed");
        _;
    }

    function register(Role role) external {
        require(role != Role.None, "Invalid role");
        roles[msg.sender] = role;
    }

    function addProduct(string memory name) external onlyManufacturer {
        productCounter++;
        Product storage p = products[productCounter];
        p.id = productCounter;
        p.name = name;
        p.currentOwner = msg.sender;
        p.state = State.Created;
        p.history.push("Created by Manufacturer");
    }

    function transferToRetailer(uint id) external onlyManufacturer {
        Product storage p = products[id];
        require(p.state == State.Created, "Product not in Created state");
        p.state = State.AtRetailer;
        p.currentOwner = msg.sender;
        p.history.push("Transferred to Retailer");
    }

    function transferToBuyer(uint id) external onlyRetailer {
        Product storage p = products[id];
        require(p.state == State.AtRetailer, "Product not at Retailer");
        p.state = State.Sold;
        p.currentOwner = msg.sender;
        p.history.push("Transferred to Buyer");
    }

    function getHistory(uint id) external view returns (string[] memory) {
        return products[id].history;
    }

    function getProduct(uint id) external view returns (uint, string memory, address, State) {
        Product storage p = products[id];
        return (p.id, p.name, p.currentOwner, p.state);
    }
}
