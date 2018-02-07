pragma solidity ^0.4.19;
contract horse {
    struct Pony {
        string name;
        uint256 locked_amount;
        
        bool for_sale;
        uint256 minimum_offer;
        uint256 current_offer;
        address current_offer_address;
        
        address owner;
        
        uint8 mane_1;
        uint8 mane_2;
        uint8 mane_3;
        uint8 coat_1;
        uint8 coat_2;
        uint8 coat_3;
    }
    
    mapping (uint256 => Pony) public pony;
    uint8 pony_counter;
    address creator;
    
    function horse() {
        pony_counter = 1;
        creator = msg.sender;
    }
    
    function new_pony(string _name, uint8 _mane_1, uint8 _mane_2, uint8 _mane_3, 
                      uint8 _coat_1, uint8 _coat_2, uint8 _coat_3) public payable {
        require(msg.value >= 0.01 ether);
        pony[pony_counter].name = _name;
        pony[pony_counter].locked_amount = msg.value;
        pony[pony_counter].minimum_offer = 0;
        pony[pony_counter].current_offer = 0;
        pony[pony_counter].current_offer_address = 0x0;
        pony[pony_counter].owner = msg.sender;
        pony[pony_counter].for_sale = false;
        pony[pony_counter].mane_1 = _mane_1;
        pony[pony_counter].mane_2 = _mane_2;
        pony[pony_counter].mane_3 = _mane_3;
        pony[pony_counter].coat_1 = _coat_1;
        pony[pony_counter].coat_2 = _coat_2;
        pony[pony_counter].coat_3 = _coat_3;
        pony_counter++; // Increase the ID of the next pony
    }
    
    function modify_pony(uint8 pony_id, string _name, uint8 _mane_1, uint8 _mane_2, uint8 _mane_3,
                         uint8 _coat_1, uint8 _coat_2, uint8 _coat_3) public payable {
        require(msg.sender == pony[pony_id].owner);
        pony[pony_id].name = _name;
        pony[pony_id].mane_1 = _mane_1;
        pony[pony_id].mane_2 = _mane_2;
        pony[pony_id].mane_3 = _mane_3;
        pony[pony_id].coat_1 = _coat_1;
        pony[pony_id].coat_2 = _coat_2;
        pony[pony_id].coat_3 = _coat_3;
    }
    
    function destroy_pony(uint8 pony_id) public {
        require(msg.sender == pony[pony_id].owner);
        pony[pony_id].name = '';
        pony[pony_id].locked_amount = 0;
        pony[pony_counter].minimum_offer = 0;
        pony[pony_counter].current_offer = 0;
        pony[pony_id].owner = 0x0;
        pony[pony_id].for_sale = false;
        pony[pony_id].mane_1 = 0;
        pony[pony_id].mane_2 = 0;
        pony[pony_id].mane_3 = 0;
        pony[pony_id].coat_1 = 0;
        pony[pony_id].coat_2 = 0;
        pony[pony_id].coat_3 = 0;
        msg.sender.transfer(pony[pony_id].locked_amount); // Release locked ether
    }
    
    function set_sale(uint8 pony_id, bool sale) public {
        require(msg.sender == pony[pony_id].owner);
        pony[pony_id].for_sale = sale; // Enable offers
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
