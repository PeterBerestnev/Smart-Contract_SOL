pragma solidity 0.8.1;

//SPDX-License-Identifier: MIT

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface DEX {
    event Bought(uint256 amount);
    event Sold(uint256 amount);
}

contract ERC20Basic is IERC20 {
    
    string public constant name = "ERC20Basic";
    string public constant symbol = "ERC";
    uint8 public constant decimals = 18;
    
    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;
    
    uint256 totalSupply_;

    using SafeMath for uint256;

    constructor(){  
	    totalSupply_ = 1000000000 * 10 ** decimals;
	    balances[msg.sender] = totalSupply_;
    }  

    function totalSupply() public override view returns (uint256) {
	    return totalSupply_;
    }
    
    function balanceOf(address owner) public override view returns (uint256) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint) {
        return allowed[owner][spender];
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(value <= balances[from]);    
        require(value <= allowed[from][msg.sender]);
    
        balances[from] = balances[from].sub(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        Transfer(from, to, value);
        return true;
    }
    
    function returnMoney(uint256 value) public  returns (bool) {
        require(value <= balances[msg.sender]);    
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[address(this)] = balances[address(this)].add(value);
        Transfer(msg.sender, address(this), value);
        return true;
    }

}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}

contract buyStage1 is DEX{

    IERC20 public token;
    uint256 public lastStage1Date = 1651508483;// 5.2.2022 

    constructor(){
        token = new ERC20Basic();
    }

    function buy() payable public {
        uint256 dexBalance = token.balanceOf(address(this));
        bool conditions = true;
        
        if (block.timestamp > lastStage1Date){
            if(dexBalance >= token.totalSupply() * 80 / 100){
                conditions = false;
            }
        }
        
        require(conditions, "We could not raise enough funds for the first stage of infesting, you can get your money back by calling the returnMyMoney function of this contract");
        require(dexBalance > uint256(token.totalSupply() * 80 / 100), "The first stage of investment is completed");
        
        uint256 amountTobuy = msg.value * 20;
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }
    
    function returnMoney() public {
        uint256 dexBalance = token.balanceOf(address(this));
        bool conditions = false;
        
        if (block.timestamp > lastStage1Date){
            if(dexBalance >= token.totalSupply() * 80 / 100){
                conditions = true;
            }
        }
        require(conditions, "You cannot return the money because the stage has not been completed yet, or it was completed successfully");
        sell(token.balanceOf(msg.sender));
    }
    
    function sell(uint256 amount) private {
        amount = amount / 20;
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }

}

contract buyStage2 is DEX{

    IERC20 public token;

    constructor(){
        token = new ERC20Basic();
    }

    function buy() payable public {
        uint256 dexBalance = token.balanceOf(address(this));
        
        require(dexBalance > uint256(token.totalSupply() * 60 / 100), "The second stage of investment is completed");
        
        uint256 amountTobuy = msg.value * 20;
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }
}

contract buyStage3 is DEX{

    IERC20 public token;

    constructor(){
        token = new ERC20Basic();
    }

    function buy() payable public {
        uint256 dexBalance = token.balanceOf(address(this));
        
        require(dexBalance > uint256(token.totalSupply() * 40 / 100), "The third stage of investment is completed");
        
        uint256 amountTobuy = msg.value * 20;
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }
}
