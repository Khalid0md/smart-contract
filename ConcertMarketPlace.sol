pragma solidity ^0.8.4;

// Secure IERC1155 multicollection minting and doubles as a marketplace
//import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import counters
//import safemath
//import IERCstuff

contract ConcertMarketPlace is ERC1155, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    string public contractName;
    string public symbol;
    uint256 fee = 1 ether;
    
    Counters.Counter private _itemIds;
    //Counters.Counter private _supplyCount;

    

    struct EventObject {
        uint256 id;
        string name;
        string description;
        uint256 totalSupply;
        address owner;
        uint256 pricePerTicket;
        uint256 maxMintAmount;
        string baseURI;
    
    }



    struct SalesObject {
        uint256 withdrawnSoFar;
        uint256 totalRevenue;
    }

   

    
        
    
    

    mapping(uint256 => EventObject) private idToEventObject;
    mapping(uint256 => Counters.Counter) private idToSupplyCount;
    mapping(uint256 => SalesObject) private idToSalesObject;
    
   
    salesObject {
        ticketsSold
        revenue
        withdrawn
    }

    

    
    mapping(uint id => salesObject) private idToSalesObject;
    
   

    event purchaseStarted (uint256 id, uint256 amount, address buyer);
    event purchaseFailed (uint256 id, uint256 amount, address buyer);
    event purchaseComplete (uint256 id, uint256 amount, address buyer, uint256 price);
    uint256[] events;
    event EventObjectCreated (
        uint256 indexed id, 
        string name,
        string description,
        uint256 totalSupply,
        address indexed owner,
        uint256 pricePerTicket,
        uint256 maxMintAmount,
        string baseURI
        );
    
    
    
    constructor() ERC1155("") {
        contractName = "NFTickets";
        symbol = "NFT";
    }
//THIS FUNCTION WORKS

function getStrLen(string memory _str) public view returns(uint) {

        uint len = bytes(_str).length;

        return len;

    }   


    function createEventObject ( 
        string memory name,
        string memory description,
        uint256 totalSupply,
        //address owner,
        uint256 pricePerTicket,
        uint256 maxMintAmount,
        string memory baseURI
    )
        external payable nonReentrant
    {
        
        require(getStrLen(name) > 0, "Event must have name");
        require(getStrLen(description) > 0, "Event must have description");
        require(totalSupply > 0, "Event must have 1 ticket to sell");
        require(pricePerTicket > 0, "Price must be at least 1 wei");
        require(maxMintAmount > 0, "Max tickets per order must be at least 1");
        require(msg.value == fee, "Must send create event fee at exact amount");
        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        EventObject memory newEvent = EventObject(
            itemId, 
            name,
            description,
            totalSupply,
            msg.sender,
            pricePerTicket,
            maxMintAmount,
            baseURI
        );

        
        events.push(newEvent.id);
        
        SalesObject memory newSales = SalesObject(
            0,
            0
        );

        idToEventObject[itemId] = newEvent;
        //idToSupplyCount[itemId] = newSale;
        emit EventObjectCreated (
            itemId, 
            name,
            description,
            totalSupply,
            msg.sender,
            pricePerTicket,
            maxMintAmount,
            baseURI
        );
    }


    function buyTicket(uint256 id, uint amount) external payable nonReentrant {
        /*emit purchaseStarted (id, amount, msg.sender);
        if (amount < 0 || amount >= idToEventObject[id].maxMintAmount || supplyCount.current().add(amount) >= idToEventObject[id].totalSupply) {
            emit purchaseFailed (id, amount, msg.sender);
        }*/
        require(amount > 0, "amount gotta be larger than 0");
        require(amount <= idToEventObject[id].maxMintAmount, "can't buy more tickets than maxmintAmount");
        require(idToSupplyCount[id].current().add(amount) <= idToEventObject[id].totalSupply, "purchase would buy more tickets than exist");
        require(msg.value == (idToEventObject[id].pricePerTicket * amount), "sent wrong amount of funds for minting tickets"); // Should I add this to if statement?
        _mint(msg.sender, id, amount, "");
        for (uint256 i = 0; i < amount; i++) {
            idToSupplyCount[id].increment();
        }
        idToSalesObject[id].totalRevenue += msg.value;
        emit purchaseComplete(id, amount, msg.sender, idToEventObject[id].pricePerTicket);
    }


    function getEvent(uint256 id) external view returns (EventObject memory) {
        return idToEventObject[id];
    }

    function getEventIds() external view returns (uint256[] memory) {
        return events;
    }

/** need return array to be memory, can't push to it because you can only push to storage arrays, can NOT push to memory arrays
    function getEvents(uint256 page, uint256 pageSize) public returns (EventObject[] memory) {
        EventObject[] storage events;
        for (uint256 i = 0; i < pageSize; i++) {
            events.push(idToEventObject[(page*pageSize) + i]);
        }
        return events;
    }
*/
  
    function withdrawFunds(uint256 id, uint256 withdrawAmount) external payable nonReentrant {
        require (idToEventObject[id].owner == msg.sender, "Must be event creator");
        require (idToSalesObject[id].totalRevenue >= idToSalesObject[id].withdrawnSoFar + withdrawAmount, "Trying to withdraw more than you've made");
        //idToSalesObject[id] = withdrawn + withdrawAmount;
        //transfer(withdrawAmount)
        idToSalesObject[id].withdrawnSoFar += withdrawAmount;
        IERC20 tokenContract = IERC20(0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0);
        tokenContract.transfer(msg.sender, withdrawAmount);
    }

    
}
