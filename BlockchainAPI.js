const Web3 = require('web3');
const fs = require('fs');
const express = require('express');

const web3 = new Web3('http://localhost:8545');
const abi = JSON.parse(fs.readFileSync('../contract/QueIdContract.abi').toString());
const contractAddress = '0xd86904659b21CcC2de2715a4fadaF432059b65e4';
const contract = new web3.eth.Contract(abi, contractAddress);
const app = express();
const port = 3000;

const options = {
    from: '0x61421EE987A668F0D498F97C9DaC8c8a5a74f65c',
    gas: 6721975,
    gasPrice: 20000000000,
};

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
    let header = '<!DOCTYPE html><html><head><title>Blockchain Log</title><style>body{color: white;background-color: black;font-family: \'Courier New\', Courier, monospace;}</style></head><body>';
    let ganacheLog = fs.readFileSync('../log').toString().split('\n').join('\n<br>\n');
    let scrollDown = '<script>window.scrollTo(0,document.body.scrollHeight);</script></body></html>';
    res.send(header + ganacheLog + scrollDown);
});

app.post('/tambahTransaksi', (req, res) => {
    contract.methods.tambahTransaksi(
        req.body.id,
        req.body.bankAsal,
        req.body.bankTujuan,
        req.body.rekAsal,
        req.body.rekTujuan,
        req.body.nominal,
        ((new Date()).getTime() / 1000),
    ).send(options, (err, result) => res.send(result));
});

app.post('/tambahIdentitas', (req, res) => {
    contract.methods.tambahIdentitas(
        req.body.id,
        req.body.nama,
        req.body.nik,
        req.body.nomor,
        req.body.alamat,
        req.body.tglLahir,
        req.body.npwp,
    ).send(options, (err, result) => res.send(result));
});

app.post('/lihatTransaksi', (req, res) => {
    contract.methods.lihatTransaksi(req.body.id).call((err, result) => res.send(result));
});

app.post('/lihatIdentitas', (req, res) => {
    contract.methods.lihatIdentitas(req.body.id).call((err, result) => res.send(result));
});

app.listen(port, () => console.log(`QUEID Blockchain API running on port ${port}`))


//contract.methods.lihatTransaksi('asdf').call((err, result) => { console.log(result) })
//web3.eth.getBlock('latest').then(console.log)
