// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IReboundPay {

     /// @dev Struct to store information about users of NFTs
    struct UserInfo 
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    /// @dev Event emitted when the user of an NFT is updated
    /// @param tokenId The NFT whose user was updated
    /// @param user The new user of the NFT
    /// @param expires The UNIX timestamp when the new user's rental period expires
    event Update(uint256 indexed tokenId, address indexed user, uint64 expires);

    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires) external;

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) external returns(address);

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) external returns(uint256);

    /// @dev Returns whether the given spender is approved for the given token id.
    /// @param sender address to check approval for
    /// @param tokenId uint256 ID of the token to check approval for
    /// @return bool whether the spender is approved for the given token id
    function isApprovedOrOwner(address sender, uint tokenId) external returns (bool);


    /// @dev Mints a new token with the given token id.
    /// @param tokenId uint256 ID of the token to mint
    function mint(uint256 tokenId) external;

    /// @dev Returns the current block timestamp.
    /// @return uint256 current block timestamp
    function time() external returns (uint256);
}