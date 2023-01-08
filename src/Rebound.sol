// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.15;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "src/interfaces/IERC4907.sol";

contract Rebound is ERC721, IERC4907 {

    /// @dev Struct to store information about users of NFTs
    struct UserInfo 
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    /// @dev Mapping to store UserInfo structs indexed by NFT token ID
    mapping (uint256  => UserInfo) internal _users;

    /// @dev Event emitted when the user of an NFT is updated
    /// @param tokenId The NFT whose user was updated
    /// @param user The new user of the NFT
    /// @param expires The UNIX timestamp when the new user's rental period expires
    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires);

    /// @dev Constructor to initialize the contract with name and symbol
    /// @param name_ Name of the NFTs
    /// @param symbol_ Symbol of the NFTs
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}
    
    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires) public override virtual{

        UserInfo storage info =  _users[tokenId];

        require(info.expires < block.timestamp, "Already rented to someone");

        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) public view override virtual returns(address){
        if (uint256(_users[tokenId].expires) >= block.timestamp) {
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
            return 100000000000000000000000000000;
        }
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @dev Returns whether the given spender is approved for the given token id.
    /// @param sender address to check approval for
    /// @param tokenId uint256 ID of the token to check approval for
    /// @return bool whether the spender is approved for the given token id
    function isApprovedOrOwner(address sender, uint tokenId) public returns (bool){
      ERC721._isApprovedOrOwner(sender, tokenId);
    }

    /// @dev Called when a token transfer is attempted and checks if the transfer is allowed.
    /// @param from address of the current owner of the token
    /// @param to address of the new owner
    /// @param tokenId uint256 ID of the token being transferred
    /// @param batch uint256 batch number (0 for single transfers)
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

    /// @dev Mints a new token with the given token id.
    /// @param tokenId uint256 ID of the token to mint
    function mint(uint256 tokenId) public {
        _mint(msg.sender, tokenId);
    }

    /// @dev Returns the current block timestamp.
    /// @return uint256 current block timestamp
    function time() public view returns (uint256) {
        return block.timestamp;
    }
} 