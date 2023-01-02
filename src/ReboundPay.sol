// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.15;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "src/IERC4907.sol";

contract ReboundPay is ERC721 {
    struct UserInfo 
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
        uint rentFee;
        uint marketplaceFee;
    }

    mapping (uint256  => UserInfo) internal _users;

    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires);

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}
    
    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires, uint rentFee, uint marketplaceFee) public  virtual{
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC4907: transfer caller is not owner nor approved");
        UserInfo storage info =  _users[tokenId];

        // require(info.expires < block.timestamp, "Already rented to someone");

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
            return 115792089237316195423570985008687907853269984665640564039457584007913129639935;
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
    function rentFee(uint256 tokenId) public view  virtual returns(uint){
        return _users[tokenId].rentFee;
    }

    /// @notice Check if an NFT is available for rent
    /// @param tokenId The NFT to check if it is available for rent
    /// @return True if the NFT is available for rent, false otherwise
    function isRentable(uint256 tokenId) public view  virtual returns(bool){
        return _users[tokenId].rentFee > 0;
    }


    function time() public view returns (uint256) {
        return block.timestamp;
    }

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

    function mint(uint256 tokenId) public {
        // this is the mint function that you need to customize for yourself
        _mint(msg.sender, tokenId);
    }

} 

// contract Rebound is ERC721, IERC4907 {

//     // need to include rental/marketplace fee
//     // need to include a set payable fee per day
//     // function to get all listings
//     // function for get listing fee
//     // function for if NFT is rentable using 4907

//     struct UserInfo 
//     {
//         address user;   // address of user role
//         uint64 expires; // unix timestamp, user expires
//         uint rentFee;
//         uint marketplaceFee;
//     }

//     // maps the tokenId to the UserInfoo
//     mapping (uint256  => UserInfo) internal _users;

//     constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}
    
//     /// @notice set the user and expires of an NFT
//     /// @dev The zero address indicates there is no user
//     /// Throws if `tokenId` is not valid NFT
//     /// @param user  The new user of the NFT
//     /// @param expires  UNIX timestamp, The new user could use the NFT before expires
//     function setUser(uint256 tokenId, address user, uint64 expires, uint rentFee, uint marketplaceFee) public  (IERC4907) virtual{
//         require(_isApprovedOrOwner(msg.sender, tokenId), "ERC4907: transfer caller is not owner nor approved");
//         UserInfo storage info =  _users[tokenId];

//         // require(info.expires < block.timestamp, "Already rented to someone");
//         // sets marketplace fee of 1%
//         marketplaceFee = rentFee * 1/100;

//         info.user = user;
//         info.expires = expires;
//         info.rentFee = rentFee;
//         info.marketplaceFee = marketplaceFee;
//         emit UpdateUser(tokenId, user, expires);
//     }

//     /// @notice Get the user address of an NFT
//     /// @dev The zero address indicates that there is no user or the user is expired
//     /// @param tokenId The NFT to get the user address for
//     /// @return The user address for this NFT
//     function userOf(uint256 tokenId) public view override virtual returns(address){
//         if (uint256(_users[tokenId].expires) >=  block.timestamp) {
//             return  _users[tokenId].user;
//         } else {
//             return ownerOf(tokenId);
//         }
//     }

//     /// @notice Get the user expires of an NFT
//     /// @dev The zero value indicates that there is no user
//     /// @param tokenId The NFT to get the user expires for
//     /// @return The user expires for this NFT
//     function userExpires(uint256 tokenId) public view override virtual returns(uint256){
//         if (uint256(_users[tokenId].expires) >=  block.timestamp) {
//             return _users[tokenId].expires;
//         } else {
//             return 10000000000000000000000000000000000000000000000000000;
//         }
//     }

//      /// @notice Get the rental fee of an NFT
//     /// @dev The zero value indicates that the NFT is not for rent
//     /// @param tokenId The NFT to get the rental fee for
//     /// @return The rental fee for this NFT (percentage of the rentPrice)
//     function rentFee(uint256 tokenId) public view  virtual returns(uint){
//         return _users[tokenId].rentFee;
//     }

//     /// @notice Check if an NFT is available for rent
//     /// @param tokenId The NFT to check if it is available for rent
//     /// @return True if the NFT is available for rent, false otherwise
//     function isRentable(uint256 tokenId) public view  virtual returns(bool){
//         return _users[tokenId].rentFee > 0;
//     }

//     /// @dev See {IERC165-supportsInterface}.
//     function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
//         return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
//     }

//     function _beforeTokenTransfer(
//         address from,
//         address to,
//         uint256 tokenId
//     ) internal virtual {
//         super._beforeTokenTransfer(from, to, tokenId, 1);

//         if (from != to && _users[tokenId].user != address(0)) {
//             delete _users[tokenId];
//             emit UpdateUser(tokenId, address(0), 0);
//         }
//     }

//     function time() public view returns (uint256) {
//         return block.timestamp;
//     }
// } 