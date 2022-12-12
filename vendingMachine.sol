```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract VendingMachine {

    // state variables
    address public owner;
    mapping (address => uint) public donutBalances;

    //edited-11/12/22
    address payable [] public userList;
    mapping (uint => address payable) public userID;
    mapping (uint => address payable) public luckyDrawHistory;

    bool public check;
    uint public id;
    uint public luckyDrawID;

    // set the owner as th address that deployed the contract
    // set the initial vending machine balance to 100
    constructor() {
        owner = msg.sender;
        donutBalances[address(this)] = 100;


        //edited-11/12/22
        check=false;
        id=1;
        luckyDrawID=1;
    }

    function getVendingMachineBalance() public view returns (uint) {
        return donutBalances[address(this)];
    }

    // Let the owner restock the vending machine
    function restock(uint amount) public {
        require(msg.sender == owner, "Only the owner can restock.");
        donutBalances[address(this)] += amount;
    }

    // Purchase donuts from the vending machine
    function purchase(uint amount) public payable {
        require(msg.value >= amount * 2 ether, "You must pay at least 2 ETH per donut");
        require(donutBalances[address(this)]>=1, "No more donuts available ");

        require(donutBalances[address(this)] >= amount, "Not enough donuts in stock to complete this purchase");
        donutBalances[address(this)] -= amount;
        donutBalances[msg.sender] += amount;


        //edited-11/12/22
        // address sender=payable(msg.sender);
        for(uint i=0; i<userList.length;i++){ 
            if(userList[i]==payable(msg.sender))
            {
                check=true;
            }
        }
        if(check==false){
            userList.push(payable(msg.sender));
            userID[id]=payable(msg.sender);
            id+=1;
        }
    }
    //edited-12/12/22
    // getting count of users purchased using vending machine

    function userCount() public view returns (uint){
        return userList.length;
    }
    //returns the address of user provided - ID
    function getUserByID(uint _id) public view returns (address) {
        require(_id <= userList.length, "UserID does not exist");
        return userID[_id];
    }
    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function pickWinner() public onlyowner {
        uint index = getRandomNumber() % userList.length;
        userList[index].transfer((address(this).balance));

        luckyDrawHistory[luckyDrawID] = userList[index];
        luckyDrawID++;
        

        // reset the state of the contract
        userList = new address payable[](0);
    }
     
     function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function getWinnerByID(uint luckyDraw) public view returns (address payable) {
        return luckyDrawHistory[luckyDraw];
    }

    modifier onlyowner() {
      require(msg.sender == owner);
      _;
    }

}
```
