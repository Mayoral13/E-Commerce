pragma solidity ^0.8.11;
import "./TokenVendor.sol";
contract ECommerce{
    using SafeMath for uint; 
    TokenVendor vendor;
    OGG myogg;
    struct Item{
        address owner;
        string name;
        uint listingprice;
        uint listingduration; 
        string description;
        bool sold;
    }
    uint private Itemcount = 1;
    uint private rate = 40000000000000;
    uint private Tokenfees;
    uint private Etherfees;
    uint private listingEtherPrice = 0.01 ether;
    uint private listingTokenAmount = 250;
    mapping(uint => Item)ItemList;
    mapping(uint => address)Lister;
    mapping(address => uint)ItemsOwned;
    mapping(address => uint)PaidTokenFee;
    mapping(address => uint)PaidEtherFee;
    mapping(uint => mapping(address =>bool))feePaid;
    mapping(uint => mapping(address =>bool))PaidItem;

    function ListItem(string memory _name,uint _price,uint _duration,string memory _description,bool _sold)public returns(bool success){
        require(feePaid[Itemcount][msg.sender] == true,"You have not paid the listing fee");
        require(_duration.add(block.timestamp) > block.timestamp,"Duration must be greater than current time");
        ItemList[Itemcount].owner = msg.sender;
        ItemList[Itemcount].name = _name;
        ItemList[Itemcount].listingprice = _price;
        ItemList[Itemcount].listingduration = _duration .add(block.timestamp);
        ItemList[Itemcount].description = _description;
        ItemList[Itemcount].sold = _sold;
        Itemcount++;
        ItemsOwned[msg.sender]++;
        Lister[Itemcount] = msg.sender;
        return true;
    }

    function PayFeeEther()public payable returns(bool success){
        require(msg.value == listingEtherPrice,"You must pay exactly 0.01 Ether");
        require(feePaid[Itemcount][msg.sender] == false,"You have already paid a fee");
        feePaid[Itemcount][msg.sender] = true;
        Etherfees = Etherfees.add(msg.value);
        PaidEtherFee[msg.sender] = PaidEtherFee[msg.sender].add(msg.value);
        return true;
    }

    function PayFeeToken(uint _value)public returns(bool success){
        require(feePaid[Itemcount][msg.sender] == false,"You have already paid a fee");
        require(_value == listingTokenAmount,"You must send exactly 250 Tokens");
        myogg.Burn(msg.sender, _value);
        myogg.Mint(address(this), _value);
        feePaid[Itemcount][msg.sender] = true;
        Tokenfees = Tokenfees.add(_value);
        PaidTokenFee[msg.sender] = PaidTokenFee[msg.sender].add(_value);
        return true;
    }

    function SearchItem(uint id)public view returns(address owner_,string memory name_,uint price_,uint duration_,string memory description_,bool sold_){
       owner_ = ItemList[id].owner;
       name_ = ItemList[id].name; 
       price_ = ItemList[id].listingprice;
       duration_ = ItemList[id].listingduration;
       description_ = ItemList[id].description;
       sold_ = ItemList[id].sold;
    }

    function BuyItemwithTokens(uint id,uint price)public returns(bool success){
     price = ItemList[id].listingprice.div(rate);
     require(ItemList[id].listingduration >= block.timestamp,"Listing Time exceeded");
     require(id != 0 ,"No such Item exists");
     require(ItemList[id].sold == false,"Item has been bought");
     require(myogg.CheckBalance(msg.sender) >= price,"Insufficient Tokens");
     require(price == ItemList[id].listingprice,"Send the Exact amount of tokens");
     myogg.Burn(msg.sender,price);
     myogg.Mint(Lister[id],price);
     ItemsOwned[msg.sender]++;
     ItemList[id].owner = msg.sender;
     PaidItem[id][msg.sender] = true;
     ItemList[id].sold = true;
     return true;
    }
     function BuyItemwithEther(uint id,uint pay)public returns(bool success){
     require(ItemList[id].listingduration >= block.timestamp,"Listing Time exceeded");
     require(id != 0 ,"No such Item exists");
     require(ItemList[id].sold == false,"Item has been bought");
     require((msg.sender).balance >= ItemList[id].listingprice,"Insufficient Balance");
     require(pay == ItemList[id].listingprice,"Input the Exact Amount");
     payable(Lister[id]).transfer(pay);
     ItemsOwned[msg.sender]++;
     ItemList[id].owner = msg.sender;
     PaidItem[id][msg.sender] = true;
     ItemList[id].sold = true;
     return true;
    }

    function ViewItemPriceETH(uint id)public view returns(uint){
    return ItemList[id].listingprice;
    }

    function ViewItemPriceTokens(uint id)public view returns(uint){
    return ItemList[id].listingprice.div(rate);
    }

    function ReturnListingETHFee()public view returns(uint){
        return listingEtherPrice;
    }
    function ReturnListingTokenFee()public view returns(uint){
        return listingTokenAmount;
    }    

    }

