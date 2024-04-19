// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// Basic Overview of The Contract: (I have explained every line so even non programmers can understand this contract)

// Store the total number of items and total items sold, payable address of owner and listing price
// by default set the owner to contract caller
// create a struct for each market item: itemId, nftaddress, tokenId, payable seller, price, sold
// create a mapping between itemId and item struct
// create events for item created and sold
// create the list and buy neft fucntions
// List nft will check if the money paid is listingfee and create a new item in mapping, transfer nft ownership to contract and emit an event
// buy nft will check if money paid is same a sprice of nft, transfer money to nft seller and transfer nft ownership to buyer, change props in mapping, emit event and pay listingfee to owner
// get market items function will check in the mapping for items not yet owned by anyone and return all those unsold items in an array
// get my NFTs will check in mapping for all items that are owned by the function caller and return an array of all these NFT
// get myCreated NFTs check in mapping for items whose seller is the function caller and returns all these items in an array

contract marketplace is ReentrancyGuard {

    uint256 _ItemsId;
    uint256 _ItemsSold;
    uint256 ListingPrice = 0.07 ether;
    address payable owner;

    // making the contract deployer (me) the owner of platform
    constructor () {
        owner = payable(msg.sender);
    }
    
    // structure of each item that will be sold on the platform
    struct Item {
        uint256 ItemId;
        uint256 price;
        uint256 tokenId;
        address nftContract;
        address payable seller;
        address payable owner;
        bool sold;
    }

    // mapping to store every item created with an itemId
    mapping (uint256 => Item) idToItem;

    // events to represent creating and selling of items
    event ItemCreated (
        uint256 ItemId,
        uint256 price,
        uint256 tokenId,
        address nftContract,
        address seller,
        address owner,
        bool sold
    );

    event ItemSold (
        uint256 ItemId,
        uint256 price,
        uint256 tokenId,
        address nftContract,
        address seller,
        address owner,
        bool sold
    );   

    function returnListingPrice () public view returns (uint256) {
        return ListingPrice;
    }

    // Listing the item as an NFT in marketplace from the data provided by seller
    function ListNFT (uint256 _price, uint256 _tokenId, address nftContract) public payable nonReentrant {
        // verify the payment
        require (msg.value > 0, "You need to pay some eth to be able to list your NFT");
        require (msg.value == ListingPrice, "Please pay the full listing fee to list an NFT");

        // create new item and add to mapping
        uint256 newItemId = _ItemsId++;
        
        idToItem[newItemId] = Item (
            newItemId,
            _price,
            _tokenId,
            nftContract,
            payable(msg.sender),
            payable(address(0)),
            false
        );

        // transfer the contract owner ship and emit item created
        IERC721(nftContract).transferFrom(msg.sender, address(this), _tokenId);

        emit ItemCreated (
            newItemId,
            _price,
            _tokenId,
            nftContract,
            payable(msg.sender),
            payable(address(0)),
            false
        );
    }

    // Buying a Listed item from marketplace
    function BuyNFT (uint256 _ItemId, address nftContract) public payable nonReentrant {
        uint256 price = idToItem[_ItemId].price;
        uint256 tokenId = idToItem[_ItemId].tokenId;

        // check the payment
        require (msg.value == price, "Please pay the full amount of NFT");

        // give payment to seller and tranfer NFT ownership to buyer
        idToItem[_ItemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        // making chnages to data
        idToItem[_ItemId].sold = true;
        idToItem[_ItemId].owner = payable(msg.sender);
        _ItemsSold++;

        // give listingprice platform fee to the owner of platform
        payable(owner).transfer(ListingPrice);

        // emit itemSold
        emit ItemSold (
            _ItemId,
            price,
            tokenId,
            nftContract,
            idToItem[_ItemId].seller,
            idToItem[_ItemId].owner,
            true
        );
    }

    // get all the items in the market that aren't sold yet
    function getMarketItems () public view returns (Item[] memory) {
        // total unsold items count and an array to store all unsold items
        uint256 unsoldItems = _ItemsId - _ItemsSold;
        Item[] memory items = new Item[](unsoldItems);

        // iterating over the mapping and adding all items to items array if their owner is empty address i.e not sold yet
        for (uint i=1; i <= _ItemsId; i++) {
            if (idToItem[i].owner == address(0)) {
                uint currentItemId = idToItem[i].ItemId;
                Item storage currentItem = idToItem[currentItemId];
                items[i - 1] = currentItem;
            }
        }
        return items;
    } 

    // get all the purchased NFTs of the specific user who calls this function
    function getMyNFTS () public view returns (Item[] memory) {
        uint256 myItemCount;

        // for every item in the mapping, if owner of an item is caller of this function, increment item count
        for (uint i=1; i <= _ItemsId; i++) {
            if (idToItem[i].owner == msg.sender) {
                myItemCount++;
            }
        }
        
        // final array to hold all items owned by the caller of this function
        Item[] memory myItems = new Item[](myItemCount);

        // loop through the entire mapping and see all items whose owner is msg.sender and return those items in the array
        for (uint256 i=1; i <= _ItemsId; i++) {
            if (idToItem[i].owner == msg.sender) {
                uint256 currentItemId = idToItem[i].ItemId;
                Item storage currentItem = idToItem[currentItemId];
                myItems[i - 1] = currentItem;
            }
        }
        return myItems;
    }

    // get all NFTs created by the caller of this function
    function getMyCreatedtNFTS () public view returns (Item[] memory) {
        uint256 mycreatedItemCount;

        // iterate over the mapping and increment itemcount for every item whose seller is the message caller
        for (uint i = 1; i <= _ItemsId; i++) {
            if (idToItem[i].seller == msg.sender) {
                mycreatedItemCount++;
            }
        }

        // final array to hold all the items
        Item[] memory myCreatedItems = new Item[](mycreatedItemCount);

        // for every entry in mapping, if an item's seller is caller of this function, add the item to the array and return
        for (uint i = 1; i <= _ItemsId; i++) {
            if (idToItem[i].seller == msg.sender) {
                uint256 currentItemId = idToItem[i].ItemId;
                Item storage currentItem = idToItem[currentItemId];
                myCreatedItems[i - 1] = currentItem;
            }
        }
        return myCreatedItems;
    }
}
