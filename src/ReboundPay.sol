// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.15;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "src/IERC4907.sol";

/// @title Rebound Pay
/// @author William Phan
/// @notice Enable renting to other users for a rental fee and marketplace fee
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.

contract ReboundPay is ERC721 {
    /// @dev Struct containing information about a user of an NFT
    struct UserInfo 
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
        uint rentFee; // rentfee
        uint marketplaceFee; // marketplace fee
    }

    /// @dev The fee charged by the marketplace for renting an NFT (percentage of the rent price)
    uint public marketplaceFee;

    /// @dev Mapping from NFT ID to user information
    mapping (uint256  => UserInfo) internal _users;

    /// @dev Event emitted when the user of an NFT is updated
    /// @param tokenId The NFT whose user was updated
    /// @param user The new user of the NFT
    /// @param expires The UNIX timestamp when the new user's rental period expires
    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires);

    /// @notice Create a new instance of the contract
    /// @param name_ The name of the ERC721 token
    /// @param symbol_ The symbol of the ERC721 token
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}
    
    ///@notice Set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to set the user and expires for
    /// @param user The new user of the NFT
    /// @param expires UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires, uint rentFee) public  virtual{
  
        UserInfo storage info =  _users[tokenId];

       require(info.expires < block.timestamp, "Already rented to someone");
        // sets marketplace fee of 1%
        marketplaceFee = rentFee * 1/100;

        info.user = user;
        info.expires = expires;
        info.rentFee = rentFee;
        info.marketplaceFee = marketplaceFee;
        emit UpdateUser(tokenId, user, expires);
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) public view  virtual returns(address){
        if (uint256(_users[tokenId].expires) >=  block.timestamp) {
            return  _users[tokenId].user;
        } else {
            return ownerOf(tokenId);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) public view  virtual returns(uint256){
        if (uint256(_users[tokenId].expires) >=  block.timestamp) {
            return _users[tokenId].expires;
        } else {
            return 100000000000000000000000000000;
        }
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @notice Get the rental fee of an NFT
    /// @dev The zero value indicates that the NFT is not for rent
    /// @param tokenId The NFT to get the rental fee for
    /// @return The rental fee for this NFT (percentage of the rentPrice)
    function getRentFee(uint256 tokenId) public view  virtual returns(uint){
        return _users[tokenId].rentFee;
    }

    /// @notice Check if an NFT is available for rent
    /// @param tokenId The NFT to check if it is available for rent
    /// @return True if the NFT is available for rent, false otherwise
    function isRentable(uint256 tokenId) public view  virtual returns(bool){
        return _users[tokenId].rentFee > 0;
    }

    /// @notice Get the current time
    /// @return The current timestamp of the block
    function time() public view returns (uint256) {
        return block.timestamp;
    }

    /// @notice Internal function that is called before an NFT is transferred
    /// @dev Overrides the base implementation to delete the user information when an NFT is transferred
    /// @param from The address the NFT is being transferred from
    /// @param to The address the NFT is being transferred to
    /// @param tokenId The NFT being transferred
    /// @param batch The batch size of the transfer (unused)
   function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 /** batch **/
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId, 1);

    if (from != to && _users[tokenId].user != address(0)) {
      delete _users[tokenId];
      emit UpdateUser(tokenId, address(0), 0);
    }
  }

    /// @notice Mint a new NFT
    /// @dev Calls the internal `_mint` function with the msg.sender as the owner
    /// @param tokenId The ID of the new NFT
    function mint(uint256 tokenId) public {
        _mint(msg.sender, tokenId);
    }
} 
