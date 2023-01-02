// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.15;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "src/IRebound.sol";

contract Rebound is ERC721, IRebound {

    // need to include rental/marketplace fee
    // need to include a set payable fee per day
    // function to get all listings
    // function for get listing fee
    // function for if NFT is rentable using 4907

    struct UserInfo 
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
        uint rentFee;
        uint marketplaceFee;
    }

    // maps the tokenId to the UserInfoo
    mapping (uint256  => UserInfo) internal _users;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}
    
    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires, uint rentFee, uint marketplaceFee) public override virtual{
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC4907: transfer caller is not owner nor approved");
        UserInfo storage info =  _users[tokenId];

        // require(info.expires < block.timestamp, "Already rented to someone");
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
    function userOf(uint256 tokenId) public view override virtual returns(address){
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
    function userExpires(uint256 tokenId) public view override virtual returns(uint256){
        if (uint256(_users[tokenId].expires) >=  block.timestamp) {
            return _users[tokenId].expires;
        } else {
            return 10000000000000000000000000000000000000000000000000000;
        }
    }

     /// @notice Get the rental price of an NFT
    /// @dev The zero value indicates that the NFT is not for rent
    /// @param tokenId The NFT to get the rental price for
    /// @return The rental price for this NFT
    function rentPrice(uint256 tokenId) public view override virtual returns(uint){
        return _users[tokenId].rentPrice;
    }

     /// @notice Get the rental fee of an NFT
    /// @dev The zero value indicates that the NFT is not for rent
    /// @param tokenId The NFT to get the rental fee for
    /// @return The rental fee for this NFT (percentage of the rentPrice)
    function rentFee(uint256 tokenId) public view override virtual returns(uint){
        return _users[tokenId].rentFee;
    }

    /// @notice Check if an NFT is available for rent
    /// @param tokenId The NFT to check if it is available for rent
    /// @return True if the NFT is available for rent, false otherwise
    function isRentable(uint256 tokenId) public view override virtual returns(bool){
        return _users[tokenId].rentPrice > 0;
    }

     function time() public view returns (uint256) {
        return block.timestamp;
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IRebound).interfaceId || super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        super._beforeTokenTransfer(from, to, tokenId, 1);

        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
    }

    function time() public view returns (uint256) {
        return block.timestamp;
    }
} 