pragma solidity ^0.4.19;
contract horse {
    struct Pony {
        uint256 locked_amount;
        
        bool for_sale;
        uint256 minimum_offer;
        uint256 current_offer;
        address current_offer_address;
        
        address owner;
        

    }
    
    struct Pony_Details {
        string name;
        uint8 mane_style;
        uint8 tail_style;
        
        uint8 mane_1;
        uint8 mane_2;
        uint8 mane_3;

        uint8 coat_1;
        uint8 coat_2;
        uint8 coat_3;
        
        uint8 accessory_1;
        uint8 accessory_2;
        uint8 accessory_3;
    }
    
    mapping (uint256 => Pony) public pony;
    mapping (uint256 => Pony_Details) public pony_details;
    uint8 pony_counter;
    address creator;
    
    function horse() {
        pony_counter = 1;
        creator = msg.sender;
    }
    
    function update_details(uint8 pony_id, string _name, uint8 _mane_style, uint8 _tail_style,
                    uint8 _mane_1, uint8 _mane_2, uint8 _mane_3,
                    uint8 _coat_1, uint8 _coat_2, uint8 _coat_3,
                    uint8 _accessory_1, uint8 _accessory_2, uint8 _accessory_3) private {
        pony_details[pony_id].name = _name;
        pony_details[pony_id].mane_1 = _mane_style;
        pony_details[pony_id].mane_1 = _tail_style;
        pony_details[pony_id].mane_1 = _mane_1;
        pony_details[pony_id].mane_2 = _mane_2;
        pony_details[pony_id].mane_3 = _mane_3;
        pony_details[pony_id].coat_1 = _coat_1;
        pony_details[pony_id].coat_2 = _coat_2;
        pony_details[pony_id].coat_3 = _coat_3;
        pony_details[pony_id].accessory_1 = _accessory_1;
        pony_details[pony_id].accessory_2 = _accessory_2;
        pony_details[pony_id].accessory_3 = _accessory_3;
    }
    
    function update_pony(uint8 pony_id, uint256 _locked_amount, bool _for_sale,
                        uint256 _minimum_offer, uint256 _current_offer,
                        address _current_offer_address, address _owner) private {
        pony[pony_id].locked_amount = _locked_amount;
        pony[pony_id].for_sale = _for_sale;
        pony[pony_id].minimum_offer = _minimum_offer;
        pony[pony_id].current_offer = _current_offer;
        pony[pony_id].current_offer_address = _current_offer_address;
        pony[pony_id].owner = _owner;
    }
    
    function new_pony(string _name, uint8 _mane_style, uint8 _tail_style,
                      uint8 _mane_1, uint8 _mane_2, uint8 _mane_3,
                      uint8 _coat_1, uint8 _coat_2, uint8 _coat_3,
                      uint8 _accessory_1, uint8 _accessory_2, uint8 _accessory_3) public payable {
        require(msg.value >= 0.01 ether);
        update_pony(pony_counter, msg.value, false, 0, 0, 0x0, msg.sender);
        update_details(pony_counter, _name, _mane_style, _tail_style, _mane_1, _mane_2, _mane_3, _coat_1, _coat_2, _coat_3, _accessory_1, _accessory_2, _accessory_3);
        pony_counter++; // Increase the ID of the next pony
    }
    
    function modify_pony(uint8 pony_id, string _name, uint8 _mane_style, uint8 _tail_style,
                         uint8 _mane_1, uint8 _mane_2, uint8 _mane_3,
                         uint8 _coat_1, uint8 _coat_2, uint8 _coat_3,
                         uint8 _accessory_1, uint8 _accessory_2, uint8 _accessory_3) public payable {
        require(msg.sender == pony[pony_id].owner);
        update_details(pony_id, _name, _mane_style, _tail_style, _mane_1, _mane_2, _mane_3, _coat_1, _coat_2, _coat_3, _accessory_1, _accessory_2, _accessory_3);
    }
    
    function destroy_pony(uint8 pony_id) public {
        require(msg.sender == pony[pony_id].owner);
        var release = pony[pony_id].locked_amount;
        update_pony(pony_id, 0, false, 0, 0, 0x0, 0x0);
        update_details(pony_id, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        msg.sender.transfer(pony[pony_id].locked_amount); // Release locked ether
    }
    
    function set_sale(uint8 pony_id, bool sale) public {
        require(msg.sender == pony[pony_id].owner);
        var ret = false;
        if(pony[pony_id].for_sale == true && pony[pony_id].current_offer_address != 0x0) {
            // If it's already for sale and someone's offered, we have to return the ether.
            var value = pony[pony_id].current_offer;
            var addr = pony[pony_id].current_offer_address;
            pony[pony_id].current_offer = 0;
            pony[pony_id].current_offer_address = 0x0;
            ret = true;
        }
        pony[pony_id].for_sale = sale; // Enable offers
        if (ret == true) {
            addr.transfer(value);
        }
    }
    
    function set_minimum_offer(uint8 pony_id, uint256 price) public {
        require(msg.sender == pony[pony_id].owner);
        pony[pony_id].minimum_offer = price; // Set the minimum offer price
        pony[pony_id].current_offer = 0; // Since there's no offers, set the current offer to 0
    }
    
    function offer(uint8 pony_id) public payable {
        require(pony[pony_id].for_sale == true);
        require(pony[pony_id].current_offer_address != msg.sender); // To increase own offer use the increase_offer() function.
        require(pony[pony_id].owner != msg.sender); // The owner can't offer.
        require(pony[pony_id].current_offer + 0.01 ether <= msg.value);
        // ^^ The new offer being made must be of value current_offer + 0.01 ether or greater.
        require(pony[pony_id].minimum_offer <= msg.value);
        // ^^ The new offer must also be greater than the minimum offer.
        var ret = false;
        if (pony[pony_id].current_offer_address != 0x0) {
            // If not the first bid
            var amount_to_send = pony[pony_id].current_offer;
            var old_bidder = pony[pony_id].current_offer_address;
            ret = true;
        }
        // Then update to the newest offer.
        pony[pony_id].current_offer = msg.value;
        pony[pony_id].current_offer_address = msg.sender;
        if (ret == true) {
            // If it was determined that it's not the first bid, then we
            // should return the previous bidder's offer lock.
            old_bidder.transfer(amount_to_send);
        }
    }
    
    function increase_offer(uint8 pony_id, uint256 new_offer) public payable {
        require(pony[pony_id].for_sale == true);
        require(new_offer - pony[pony_id].current_offer == msg.value); // Increase in offer == ether sent
        require(pony[pony_id].current_offer_address == msg.sender);
        pony[pony_id].current_offer = msg.value;
    }
    
    function accept_offer(uint8 pony_id, address intended) public {
        require(msg.sender == pony[pony_id].owner);
        require(pony[pony_id].current_offer_address != 0x0); // Reject if nobody's offered
        require(pony[pony_id].current_offer_address == intended); 
        // ^^^ This is to prevent offer sniping. If the current offer address is changed
        // before this transaction goes through, it will revert.
        var amount_to_send = pony[pony_id].current_offer;
        var send_to =  pony[pony_id].current_offer_address;
        pony[pony_id].current_offer = 0;
        pony[pony_id].current_offer_address = 0x0;
        pony[pony_id].owner = pony[pony_id].current_offer_address;
        send_to.transfer(amount_to_send);
    }
    
}
