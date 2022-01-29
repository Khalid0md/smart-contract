// SPDX-License-Identifier: MIT
// Created by @0mdur - Khalid Hamid
// Learned from @Hashlipsnft - Hashlips
// gas optimization Inspired by @0xFloop

pragma solidity >=0.7.0 <0.9.0;

//import "ERC721.sol";

//import "Ownable.sol";

//import "SafeMath.sol";

//import "Counters.sol";

contract NFT is ERC721, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private tokenSupply;
    string public baseURI;
    string public baseExtension = ".json";
    string public notRevealedUri;
    uint256 public cost = 0.05 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmount = 10;
    uint256 public mintLimit = 3;
    bool public paused = false;
    bool public revealed = false;
    bool public presale = true;
    address[] public whitelist;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(uint256 _amount) public payable {
        require(!paused);

        require(_amount > 0);
        require(_amount <= maxMintAmount);
        require(tokenSupply.current().add(_amount) <= maxSupply);

        if (msg.sender != owner()) {
            if (presale == true) {
                require(isWhiteListed(msg.sender), "user is not whitelisted");
                uint256 tokenCount = balanceOf(msg.sender);
                require(tokenCount < mintLimit);
            }
        }

        for (uint256 i = 1; i <= _amount; i++) {
            //ERC721Enumerable totalSupply()
            //_safeMint(msg.sender, supply + i);

            //using counters.sol to reduce gas
            tokenSupply.increment();
            uint256 newId = tokenSupply.current();
            _safeMint(msg.sender, newId);
        }
    }

    function isWhiteListed(address _user) public view returns (bool) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    //only owner
    function reveal() public onlyOwner {
        revealed = true;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setLimit(uint256 _newLimit) public onlyOwner {
        mintLimit = _newLimit;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function setOnlyPresale(bool _state) public onlyOwner {
        presale = _state;
    }

    function addToWhiteList(address[] calldata _users) public onlyOwner {
        delete whitelist;
        whitelist = _users;
    }

    function withdraw() public payable onlyOwner {
        // This will payout the owner the balance in the contract.
        // Do not remove this otherwise you will not be able to withdraw the funds.
        // =============================================================================
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
        // =============================================================================
    }
}
