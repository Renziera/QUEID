const functions = require('firebase-functions');
const request = require('request-promise-native');

exports.penggunaBaru = functions.firestore.document('pengguna/{id}').onCreate(async (snap, context) => {
    const data = snap.data();

    try {
        let result = await request.post('http://blockchain.que-id.com/tambahIdentitas', {
            form: {
                id: snap.id,
                nama: data.nama,
                nik: data.nik,
                nomor: data.nomor,
                alamat: data.alamat,
                tglLahir: data.tglLahir.toString(),
                npwp: data.npwp,
            },
        });
        await snap.ref.update({ transaction: result });
    } catch (error) {

    }
});

exports.transaksiMasuk = functions.firestore.document('/pengguna/{pengguna_id}/mutasi/{id}').onCreate(async (snap, context) => {
    const data = snap.data();

    if(!data.send) return;

    try {
        let result = await request.post('http://blockchain.que-id.com/tambahTransaksi', {
            form: {
                id: snap.id,
                bankAsal: data.bank_asal,
                bankTujuan: data.bank_tujuan,
                rekAsal: data.rek_asal.toString(),
                rekTujuan: data.rek_tujuan.toString(),
                nominal: data.nominal,
            },
        });
        await snap.ref.update({ transaction: result });
    } catch (error) {

    }
});