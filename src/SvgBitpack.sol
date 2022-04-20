// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./stuff/ERC721.sol";
import "./stuff/Ownable.sol";
import "./stuff/Strings.sol";
import "./stuff/Base64.sol";
import "./stuff/ToHex.sol";

error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();
error WithdrawTransfer();
error NotTheOwner();

contract SvgBitpack is ERC721, Ownable {
   using Strings for uint24;
   using ToHex for uint24;

    string public baseURI;
    uint256 public currentTokenId;
    // Max supply can be 4,294,967,295 if using 8 attributes
    uint256 public constant TOTAL_SUPPLY = 10_000;

    mapping(uint256 => uint256) public attributes;

    // External contract
    Base64 base64;

    struct svg {
        string[] svgpiece;
    }
  
    svg Svg;

    constructor(
        string memory _name,
        string memory _symbol,
        Base64 _base64
    ) ERC721(_name, _symbol) {
        base64 = _base64;
        // Color  | #0
        Svg.svgpiece.push("<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><rect width='100%' height='100%' fill='url(#pattern)' /><defs><linearGradient id='gradient' x1='100%' y1='10%' x2='0%' y2='10%'><stop offset='6.25%' stop-color='#");
        // Color  | #1
        Svg.svgpiece.push("'/><stop offset='18.75%' stop-color='#");
        // Color  | #2
        Svg.svgpiece.push("'/><stop offset='31.25%' stop-color='#");
        // Color  | #3
        Svg.svgpiece.push("'/><stop offset='56.25%' stop-color='#");
        // Color  | #4
        Svg.svgpiece.push("'/><stop offset='68.75%' stop-color='#");
        // Color  | #5
        Svg.svgpiece.push("'/><stop offset='81.25%' stop-color='#");
        // Color  | #6
        Svg.svgpiece.push("'/><stop offset='93.75%' stop-color='#");
        // Color  | #7
        Svg.svgpiece.push("'/><stop offset='100%' stop-color='#");
        // Speed  | #8
        Svg.svgpiece.push("'/></linearGradient></defs><pattern id='pattern' x='0' y='0' width='400%' height='100%' patternUnits='userSpaceOnUse'><rect x='-150%' y='0' width='200%' height='100%' fill='url(#gradient)' transform='rotate(-65)'><animate attributeType='XML' attributeName='x' from='-150%' to='50%' dur='");
        // Speed2 | #9
        Svg.svgpiece.push("ms' repeatCount='indefinite'/></rect><rect x='-350%' y='0' width='200%' height='100%' fill='url(#gradient)' transform='rotate(-65)'><animate attributeType='XML' attributeName='x' from='-350%' to='-150%' dur='");
        // Final  | #10
        Svg.svgpiece.push("ms' repeatCount='indefinite'/></rect></pattern></svg>");
    }



    function mintTo(address recipient) public payable returns (uint256) {
        uint256 newTokenId = ++currentTokenId;

        if (newTokenId > TOTAL_SUPPLY) {
            revert MaxSupply();
        }

        uint256 attributes_ = attributes[newTokenId];
    
        assembly {                                          // Colors
        attributes_ := add(attributes_, 0x87FFFE)           // 0
        attributes_ := add(attributes_, shl(24, 0x88FF89))  // 1
        attributes_ := add(attributes_, shl(48, 0xF8F58A))  // 2
        attributes_ := add(attributes_, shl(72, 0xEF696A))  // 3
        attributes_ := add(attributes_, shl(96, 0xF36ABA))  // 4
        attributes_ := add(attributes_, shl(120, 0xEF696A)) // 5
        attributes_ := add(attributes_, shl(144, 0xF8F58A)) // 6
        attributes_ := add(attributes_, shl(168, 0x88FF89)) // 7
        attributes_ := add(attributes_, shl(216, 10000)) // Speed | 10,000ms (milli)
        }

        attributes[newTokenId] = attributes_;

        _safeMint(recipient, newTokenId);
        return newTokenId;
    }

    
    function tokenURI(uint256 tokenId)
        public
        virtual
        view
        override
        returns (string memory)
    {
        if (ownerOf[tokenId] == address(0)) {
            revert NonExistentTokenURI();
        }

    string memory render1 = render_1(tokenId);
    string memory render2 = render_2(tokenId);
    string memory render3 = render_3(tokenId);
    
    string memory finalSvg = string(abi.encodePacked(
       render1,
       render2,
       render3
        ));

    string memory json = base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Rainbow", "description": "Bitpacked Rainbow on chain", "image": "data:image/svg+xml;base64,',
                        // Add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );
        
        string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

        return finalTokenUri;
    }


    // Transfer from message sender to receiver address
    function _transfer(address to, uint256 id) external {
        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            --balanceOf[msg.sender];

            ++balanceOf[to];
        }

        ownerOf[id] = to;

        emit Transfer(address(msg.sender), to, id);
    }

    /// READ FUNCTIONS ///

    function render_1(uint256 tokenId) internal view returns (string memory) {
        uint256 attributes_ = attributes[tokenId];
    
        // attributes
        uint24 a0;
        uint24 a1;
        uint24 a2;
        uint24 a3;

        string memory partialSvg;
        // Thank you v much Optimism team!
        assembly {
            a0 := and(
                    attributes_,
                    0x0000000000000000000000000000000000000000000000000000000000FFFFFF
                  
            )

            a1 := shr(
                24,
                and(
                    attributes_,
                    0x0000000000000000000000000000000000000000000000000000FFFFFF000000)
            )

            a2 := shr(
                48,
                and(
                    attributes_,
                    0x0000000000000000000000000000000000000000000000FFFFFF000000000000)
            ) 

            a3 := shr(
                72,
                and(
                    attributes_,
                    0x0000000000000000000000000000000000000000FFFFFF000000000000000000)
            )       

    }

    return  partialSvg = string(abi.encodePacked(
        Svg.svgpiece[0],
        a0.uint24tohexstr(),
        Svg.svgpiece[1],
        a1.uint24tohexstr(),
        Svg.svgpiece[2],
        a2.uint24tohexstr(),
        Svg.svgpiece[3],
        a3.uint24tohexstr()
          
    ));
    }

    function render_2(uint256 tokenId) internal view returns (string memory) {
        uint256 attributes_ = attributes[tokenId];
    
        // attributes
        uint24 a4;
        uint24 a5;
        uint24 a6;
        uint24 a7;

        string memory partialSvg;
        // Thank you v much Optimism team!
        assembly {
           
            a4 := shr(
                96,
                and(
                    attributes_,
                    0x0000000000000000000000000000000000FFFFFF000000000000000000000000)
            )       

            a5 := shr(
                120,
                and(
                    attributes_,
                    0x0000000000000000000000000000FFFFFF000000000000000000000000000000)
            ) 

            a6 := shr(
                144,
                and(
                    attributes_,
                    0x0000000000000000000000FFFFFF000000000000000000000000000000000000)
            ) 

            a7 := shr(
                168,
                and(
                    attributes_,
                    0x0000000000000000FFFFFF000000000000000000000000000000000000000000)
            )       
    }

    return partialSvg = string(abi.encodePacked(
        Svg.svgpiece[4],
        a4.uint24tohexstr(),
        Svg.svgpiece[5],
        a5.uint24tohexstr(),
        Svg.svgpiece[6],
        a6.uint24tohexstr(),
        Svg.svgpiece[7],
        a7.uint24tohexstr()
    ));
    }

    function render_3(uint256 tokenId) internal view returns (string memory) {
        uint256 attributes_ = attributes[tokenId];
        uint24 speed;
        string memory partialSvg;

        assembly {
     
            speed := shr(
                216,
                and(
                    attributes_,
                    0x0000FFFFFF000000000000000000000000000000000000000000000000000000
                )
            )
        }

        return  partialSvg = string(abi.encodePacked(
        Svg.svgpiece[8],
        speed.toString(),
        Svg.svgpiece[9],
        speed.toString(),
        Svg.svgpiece[10]
    ));

    }
}
