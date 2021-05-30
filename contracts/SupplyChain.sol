pragma solidity ^0.4.24;

contract supplyChain {
    uint32 public p_id = 0;   // Product ID
    uint32 public u_id = 0;   // Participant ID
    uint32 public r_id = 0;   // Registration ID

    struct product {
        string  modelNumber;
        string  partNumber;
        string  serialNumber;
        address productOwner;
        uint32  cost;
        uint32  mfgTimeStamp;
    }

    // products[p_id] => product
    mapping(uint32 => product) public products;

    struct participant {
        string  userName;
        string  password;
        string  participantType;
        address participantAddress;
    }

    // participants[u_id] => participant
    mapping(uint32 => participant) public participants;

    struct registration {
        uint32  productId;
        uint32  ownerId;
        uint32  trxTimeStamp;
        address productOwner;
    }

    // regstrations[r_id] => registration
    mapping(uint32 => registration) public registrations; // Registrations by Registration ID (r_id)

    // productTrack[p_id] => registrations
    mapping(uint32 => uint32[])     public productTrack;  // Registrations by Product ID (p_id) / Movement track for a product

    event Transfer(uint32 productId);

    // -------------------------------------------------------------------------
    // Create a participant
    // -------------------------------------------------------------------------
    function createParticipant(string _name,
                               string _pass,
                               address _pAdd,
                               string _pType)
                               public
                               returns (uint32)
    {
        uint32 userId = u_id++;

        participants[userId].userName           = _name ;
        participants[userId].password           = _pass;
        participants[userId].participantAddress = _pAdd;
        participants[userId].participantType    = _pType;

        return userId;
    }

    // -------------------------------------------------------------------------
    // Get details of a specified participant
    // -------------------------------------------------------------------------
    function getParticipantDetails(uint32 _p_id)
                                   public view
                                   returns (string,address,string)
    {
        return (participants[_p_id].userName,
                participants[_p_id].participantAddress,
                participants[_p_id].participantType);
    }

    // -------------------------------------------------------------------------
    // Create a product
    // -------------------------------------------------------------------------
    function createProduct(uint32 _ownerId,
                           string _modelNumber,
                           string _partNumber,
                           string _serialNumber,
                           uint32 _productCost)
                           public
                           returns (uint32)
    {
        if (keccak256(abi.encodePacked(participants[_ownerId].participantType)) == keccak256("Manufacturer"))
        {
            uint32 productId = p_id++;

            products[productId].modelNumber  = _modelNumber;
            products[productId].partNumber   = _partNumber;
            products[productId].serialNumber = _serialNumber;
            products[productId].cost         = _productCost;
            products[productId].productOwner = participants[_ownerId].participantAddress;
            products[productId].mfgTimeStamp = uint32(now);

            return productId;
        }

       return 0;
    }

    // -------------------------------------------------------------------------
    // Only owner
    // -------------------------------------------------------------------------
    modifier onlyOwner(uint32 _productId) {
         require(msg.sender == products[_productId].productOwner );
         _;
    }

    // -------------------------------------------------------------------------
    // Get details of a speified product
    // -------------------------------------------------------------------------
    function getProductDetails(uint32 _productId)
                               public view
                               returns (string, string, string, uint32, address, uint32)
    {
        return (products[_productId].modelNumber,
                products[_productId].partNumber,
                products[_productId].serialNumber,
                products[_productId].cost,
                products[_productId].productOwner,
                products[_productId].mfgTimeStamp);
    }

    // -------------------------------------------------------------------------
    // Transfer a specified product
    // -------------------------------------------------------------------------
    function transferToOwner(uint32 _user1Id,
                             uint32 _user2Id,
                             uint32 _prodId)
                             onlyOwner(_prodId)
                             public
                             returns(bool)
    {
        participant memory p1 = participants[_user1Id];
        participant memory p2 = participants[_user2Id];
        uint32 registration_id = r_id++;

        if(keccak256(abi.encodePacked(p1.participantType)) == keccak256("Manufacturer") &&
           keccak256(abi.encodePacked(p2.participantType)) == keccak256("Supplier"))
        {
            registrations[registration_id].productId    = _prodId;
            registrations[registration_id].productOwner = p2.participantAddress;
            registrations[registration_id].ownerId      = _user2Id;
            registrations[registration_id].trxTimeStamp = uint32(now);

            products[_prodId].productOwner              = p2.participantAddress;

            productTrack[_prodId].push(registration_id);

            emit Transfer(_prodId);

            return (true);
        }
        else if(keccak256(abi.encodePacked(p1.participantType)) == keccak256("Supplier") &&
                keccak256(abi.encodePacked(p2.participantType)) == keccak256("Supplier"))
        {
            registrations[registration_id].productId    = _prodId;
            registrations[registration_id].productOwner = p2.participantAddress;
            registrations[registration_id].ownerId      = _user2Id;
            registrations[registration_id].trxTimeStamp = uint32(now);

            products[_prodId].productOwner              = p2.participantAddress;

            productTrack[_prodId].push(registration_id);

            emit Transfer(_prodId);

            return (true);
        }
        else if(keccak256(abi.encodePacked(p1.participantType)) == keccak256("Supplier") &&
                keccak256(abi.encodePacked(p2.participantType)) == keccak256("Consumer"))
        {
            registrations[registration_id].productId    = _prodId;
            registrations[registration_id].productOwner = p2.participantAddress;
            registrations[registration_id].ownerId      = _user2Id;
            registrations[registration_id].trxTimeStamp = uint32(now);

            products[_prodId].productOwner              = p2.participantAddress;

            productTrack[_prodId].push(registration_id);

            emit Transfer(_prodId);

            return (true);
        }

        return (false);
    }

    // -------------------------------------------------------------------------
    // Get product track
    // -------------------------------------------------------------------------
    function getProductTrack(uint32 _prodId) external view returns (uint32[]) {

       return productTrack[_prodId];
    }

    // -------------------------------------------------------------------------
    // Get details of a specifed registration
    // -------------------------------------------------------------------------
    function getRegistrationDetails(uint32 _regId)  public view returns (uint32,uint32,address,uint32) {

        registration memory r = registrations[_regId];

        return (r.productId,r.ownerId,r.productOwner,r.trxTimeStamp);
    }

    // -------------------------------------------------------------------------
    // Authentiate a specifed participant
    // -------------------------------------------------------------------------
    function authenticateParticipant(uint32 _uid,
                                     string _uname,
                                     string _pass,
                                     string _utype)
                                     public view 
                                     returns (bool)
    {
        if(keccak256(abi.encodePacked(participants[_uid].participantType)) == keccak256(abi.encodePacked(_utype))) {
            if(keccak256(abi.encodePacked(participants[_uid].userName)) == keccak256(abi.encodePacked(_uname))) {
                if(keccak256(abi.encodePacked(participants[_uid].password)) ==keccak256(abi.encodePacked(_pass))) {
                    return (true);
                }
            }
        }

        return (false);
    }
}
