pragma solidity ^0.5.1;

contract QueIdContract {
    mapping(string => Transaksi) transactions;
    mapping(string => Identitas) identities;
    
    address queId;
    
    modifier onlyQueId(){
        require(msg.sender == queId);
        _;
    }
    
    struct Transaksi {
        string _idBankAsal;
        string _idBankTujuan;
        string _rekAsal;
        string _rekTujuan;
        uint _nominal;
        uint256 _waktu;
    }
    
    struct Identitas {
        string _nama;
        string _nik;
        string _nomor;
        string _alamat;
        string _tglLahir;
        string _npwp;
    }
    
    constructor() public {
        queId = msg.sender;
    }
    
    function tambahTransaksi(
        string memory _id, 
        string memory _idBankAsal, 
        string memory _idBankTujuan, 
        string memory _rekAsal,
        string memory _rekTujuan,
        uint  _nominal,
        uint256 _waktu
    ) public onlyQueId {
        transactions[_id] = Transaksi(_idBankAsal, _idBankTujuan, _rekAsal, _rekTujuan, _nominal, _waktu);
    }
    
    function tambahIdentitas(
        string memory _id,
        string memory _nama, 
        string memory _nik, 
        string memory _nomor, 
        string memory _alamat, 
        string memory _tglLahir, 
        string memory _npwp
    ) public onlyQueId {
        identities[_id] = Identitas(_nama, _nik, _nomor, _alamat, _tglLahir, _npwp);
    }
    
    function lihatTransaksi(string memory _id) public view returns(string memory){
        Transaksi memory t = transactions[_id];
        return append(t._idBankAsal, t._idBankTujuan, t._rekAsal, t._rekTujuan, uint2str(t._nominal), uint2str(t._waktu));
    }
    
    function lihatIdentitas(string memory _id) public view returns(string memory){
        Identitas memory i = identities[_id];
        return append(i._nama, i._nik, i._nomor, i._alamat, i._tglLahir, i._npwp);
    }
    
    function uint2str(uint _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
    
    function append(
        string memory a, 
        string memory b, 
        string memory c, 
        string memory d, 
        string memory e, 
        string memory f
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(a, '#', b, '#', c, '#', d, '#', e, '#', f));
    }
    
}
