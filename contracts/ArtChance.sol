// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtChance is ERC721URIStorage, Ownable {
    uint256 public ticketPrice;
    uint256 public totalTickets;
    uint256 public ticketCounter;
    uint256 public roundCounter;
    uint256 public drawTime;
    bool public isActive;

    mapping(uint256 => address) public ticketOwners;
    mapping(uint256 => string) public roundURIs;

    event TicketPurchased(uint256 indexed ticketId, address buyer);
    event WinnerDrawn(uint256 indexed round, address winner, uint256 tokenId);

    constructor(uint256 _ticketPrice, uint256 _drawTimeInSeconds) ERC721("ArtChance", "ARTC") Ownable(msg.sender) {
        ticketPrice = _ticketPrice;
        drawTime = block.timestamp + _drawTimeInSeconds;
        isActive = true;
    }

    function buyTicket() external payable {
        require(isActive, "Lottery is not active");
        require(msg.value == ticketPrice, "Incorrect ticket price");

        ticketOwners[ticketCounter] = msg.sender;
        emit TicketPurchased(ticketCounter, msg.sender);
        ticketCounter++;
        totalTickets++;
    }

    function setRoundTokenURI(uint256 roundId, string memory uri) external onlyOwner {
        roundURIs[roundId] = uri;
    }

    function drawWinner() external onlyOwner {
        require(isActive, "Already drawn");
        require(block.timestamp >= drawTime, "Draw time not reached");
        require(totalTickets > 0, "No tickets sold");

        uint256 winningTicket = uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1)))) % totalTickets;
        address winner = ticketOwners[winningTicket];

        _safeMint(winner, roundCounter);
        _setTokenURI(roundCounter, roundURIs[roundCounter]);

        emit WinnerDrawn(roundCounter, winner, roundCounter);

        // Reset state
        roundCounter++;
        ticketCounter = 0;
        totalTickets = 0;
        isActive = false;
    }

    function startNewRound(uint256 newDrawDelayInSeconds) external onlyOwner {
        require(!isActive, "Current round active");
        drawTime = block.timestamp + newDrawDelayInSeconds;
        isActive = true;
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}