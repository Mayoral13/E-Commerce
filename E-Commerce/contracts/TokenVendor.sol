pragma solidity ^0.8.11;
import "./OGGToken.sol";
contract TokenVendor{
    OGG myogg;
    using SafeMath for uint;
    uint private Circulation;
    address private owner;
    uint private rate = 40000000000000;
    mapping(address => uint)Bought;
    mapping(address => uint)Sold;
    event rateSet(address indexed _from,uint _value);
    event ownerChange(address indexed _from,address indexed _to);
    event tokensBought(address indexed _from,uint _value);
    event tokensSold(address indexed _from,uint _value);
    event withdraw(address indexed _from,address indexed _to,uint _value);
    

    constructor(address tokenAddress){
        myogg = OGG(tokenAddress);
    }
    function ShowRate()external view returns(uint){
        return rate;
    }
    function SetRate(uint _rate)external returns(bool success){
        require(msg.sender == owner,"You are not the Owner");
        require(_rate != 0,"Rate cannot be 0");
        rate = _rate;
        emit rateSet(msg.sender,_rate);
        return true;

    }
    function ShowOwner()external view returns(address){
        return owner;
    }

    function ChangeOwner(address _owner)external returns(bool success){
        require(msg.sender == owner,"You are not the owner");
        require(_owner != address(0),"New owner cannot be zero address");
        owner = _owner;
        emit ownerChange(msg.sender,_owner);
        return true;
    }


    function BuyTokens()external payable returns(bool success){
        uint VendorBalance = myogg.CheckBalance(address(this));
        require(rate != 0,"Rate has not been set");
        require(msg.value != 0,"You cannot send nothing");
        uint bought = msg.value.div(rate);
        require(VendorBalance >= bought,"Amount is too high");
        bought = msg.value.div(rate);
        myogg.Mint(msg.sender,bought);
        myogg.Burn(address(this),bought);
        Circulation = Circulation.add(bought);
        emit tokensBought(msg.sender,bought);
        return true;
    }

     function SellTokens(uint amount)external returns(bool success){
        uint sold = amount.mul(rate);
        uint UserBalance = myogg.CheckBalance(msg.sender);
        require(amount != 0,"You cannot sell nothing");
        require(UserBalance >= amount,"Insufficient Amount Of Tokens");
        require(rate != 0,"Rate has not been set");
        require(BalanceVendor() >= sold,"Insufficient Cash");
        payable(msg.sender).transfer(sold);
        myogg.Mint(address(this),amount);
        myogg.Burn(msg.sender,amount);
        Circulation = Circulation.sub(sold);
        emit tokensSold(msg.sender,amount);
        return true;
    }

    function TokeninCirculation()external view returns(uint){
        return Circulation;
    }

    function Withdraw(address payable _to,uint amount)external payable returns(bool success){
        require(msg.sender == owner,"You are not the owner");
        require(address(this).balance >= amount,"Insufficient Balance");
        _to.transfer(amount);
        emit withdraw(msg.sender,_to,amount);
        return true;
    }
    function BalanceVendor()public view returns(uint){
        return address(this).balance;
    }
    function VendorTokenBalance()public view returns(uint){
        return myogg.CheckBalance(address(this));
    }

    function TokenBalance()public view returns(uint){
        return myogg.CheckBalance(msg.sender);
    }
    function ETHBalance()public view returns(uint){
        return (msg.sender).balance;
    }
    
}