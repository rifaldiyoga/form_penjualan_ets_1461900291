import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'custom/custom_widget.dart';
import 'package:intl/intl.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class FormPage extends StatefulWidget {
  const FormPage({Key? key}) : super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

enum RadioCharacter { y, n }

class _FormPageState extends State<FormPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final viewKey = GlobalKey();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _txtNoNota = new TextEditingController();
  TextEditingController _txtNamaPembeli = new TextEditingController();
  TextEditingController _txtTglPembelian = new TextEditingController();
  TextEditingController _txtJmlhPembelian = new TextEditingController();
  TextEditingController _txtDiskon = new TextEditingController();
  TextEditingController _txtPpn = new TextEditingController();
  TextEditingController _txtKembalian = new TextEditingController();
  ScrollController _scrollController = ScrollController();

  List<String> jenisBarangList = ["ABC", "BBB", "XYZ", "WWW"];
  List<String> jenisList = ["Biasa", "Pelanggan", "Pelanggan Istimewa"];

  String jenis = 'Biasa';

  List<String> jenisBrgValList = <String>[];
  RadioCharacter? hariLibur = RadioCharacter.y;
  RadioCharacter? saudara = RadioCharacter.y;

  DateTime tglPembelian = new DateTime(1000);
  bool isSelected = false;

  final f = new DateFormat('yyyy-MM-dd');

  double marginBetween = 16;

  FocusNode _fnNIM = FocusNode();

  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  double diskonAmt = 0;
  double taxAmt = 0;
  double ppn = 0;
  double grandtotal = 0;
  double kembalian = 0;

  @override
  Widget build(BuildContext context) {
    _imgFromCamera() async {
      XFile? image =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

      setState(() {
        _image = image;
      });
    }

    _imgFromGallery() async {
      XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);

      setState(() {
        _image = image;
      });
    }

    void _showPicker(context) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return SafeArea(
              child: Container(
                child: new Wrap(
                  children: <Widget>[
                    new ListTile(
                        leading: new Icon(Icons.photo_library),
                        title: new Text('Photo Library'),
                        onTap: () {
                          _imgFromGallery();
                          Navigator.of(context).pop();
                        }),
                    new ListTile(
                      leading: new Icon(Icons.photo_camera),
                      title: new Text('Camera'),
                      onTap: () {
                        _imgFromCamera();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }

    buildMaterialDatePicker(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      );
      if (picked != null && picked != tglPembelian)
        setState(() {
          _txtTglPembelian.text = f.format(picked);
        });
    }

    isHobySelected(String val) {
      for (int i = 0; i < jenisBrgValList.length; i++) {
        if (val == jenisBrgValList[i]) return true;
      }
      return false;
    }

    Widget checkbox() {
      return Column(
        children: [
          for (var i = 0; i < jenisBarangList.length; i++)
            LabeledCheckbox(
                label: jenisBarangList[i],
                padding: EdgeInsets.all(0),
                value: isHobySelected(jenisBarangList[i]),
                onChanged: () {
                  setState(() {
                    jenisBrgValList.add(jenisBarangList[i]);
                  });
                }),
        ],
      );
    }

    Widget foto() {
      return Container(
        constraints: BoxConstraints(
          minHeight: 200,
          minWidth: 200,
        ),
        child: Column(
          children: [
            Card(
                child: Column(
              children: [
                _image != null
                    ? Image.file(
                        File(
                          _image!.path,
                        ),
                        width: 300,
                        height: 300,
                      )
                    : Image.asset(
                        'assets/image.jpg',
                        width: 300,
                        height: 300,
                      ),
              ],
            )),
            RaisedButton(
                child: Text("Pick Image"),
                onPressed: () {
                  _showPicker(context);
                }),
          ],
        ),
      );
    }

    void reset() {
      setState(() {
        diskonAmt = 0;
        grandtotal = 0;
        kembalian = 0;
      });
      _txtNoNota.text = "";
      _txtNamaPembeli.text = "";
      _txtTglPembelian.text = "";
      _txtJmlhPembelian.text = "";
      _txtDiskon.text = "";
      _txtPpn.text = "";
      _txtKembalian.text = "";
      _image = null;
      jenisBrgValList = [];
      hariLibur = RadioCharacter.y;
      saudara = RadioCharacter.y;
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    }

    void proses() {
      setState(() {
        double jmlPembelian = double.parse(_txtJmlhPembelian.text);
        double bayar = double.parse(_txtKembalian.text);
        int diskon = int.parse(_txtDiskon.text.replaceAll(new RegExp('%'), ""));
        int ppn = int.parse(_txtPpn.text.replaceAll(new RegExp('%'), ""));

        bool hl = hariLibur == RadioCharacter.y;
        bool sdr = hariLibur == RadioCharacter.y;

        if (diskon > 0) {
          diskonAmt = jmlPembelian * diskon / 100;
          grandtotal = jmlPembelian - diskonAmt;
        }

        if (hl) grandtotal -= 2500;

        grandtotal = sdr ? grandtotal - 5000 : grandtotal + 3000;

        for (String a in jenisBrgValList) {
          if (a == "ABC") grandtotal += 100;
          if (a == "XYZ") grandtotal += 200;
          if (a == "BBB") grandtotal += 500;
          if (a == "WWW") grandtotal += 100;
        }

        if (ppn > 0) {
          taxAmt = grandtotal * ppn / 100;
          grandtotal = grandtotal + taxAmt;
        }

        kembalian = bayar - grandtotal;
      });

      print(_image!.path);
      Future.delayed(Duration(milliseconds: 600), () {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      });
    }

    void validateInput() {
      FormState? form = this.formKey.currentState;
      ScaffoldState? scaffold = this.scaffoldKey.currentState;
      SnackBar message = SnackBar(
        content: Text('Proses validasi berhasil!'),
      );

      if (form!.validate()) {
        proses();
      }
    }

    Widget buttonProses() {
      return Row(
        children: [
          Expanded(
              child: ButtonTheme(
                  child: RaisedButton(
                      child: Text(
                        "Proses",
                        style: TextStyle(color: Color(0xffFFFFFF)),
                      ),
                      onPressed: () {
                        validateInput();
                      }))),
          SizedBox(
            width: 8,
          ),
          Expanded(
              child: ButtonTheme(
                  child: RaisedButton(
                      child: Text("Reset",
                          style: TextStyle(color: Color(0xffFFFFFF))),
                      onPressed: () {
                        reset();
                        // FocusScope.of(context).requestFocus(_fnNIM);
                      })))
        ],
      );
    }

    Widget formInput() {
      return Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            CustomTextField(
              textInputType: TextInputType.phone,
              hintText: "Masukkan No Nota",
              labelText: "No Nota",
              controller: _txtNoNota,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(
              height: marginBetween,
            ),
            CustomTextField(
              hintText: "Masukkan Nama Pembeli",
              labelText: "Nama Pembeli",
              textInputAction: TextInputAction.next,
              controller: _txtNamaPembeli,
            ),
            SizedBox(
              height: marginBetween,
            ),
            CustomTextField(
              hintText: "Masukkan Tanggal Beli",
              labelText: "Tanggal Beli",
              controller: _txtTglPembelian,
              initValue: tglPembelian.toString(),
              textInputAction: TextInputAction.done,
              textInputType: TextInputType.datetime,
              onTap: () {
                buildMaterialDatePicker(context);
              },
            ),
            SizedBox(
              height: marginBetween,
            ),
            CustomDropDown(
                value: jenis,
                itemList: jenisList,
                onChanged: (data) {
                  setState(() {
                    jenis = data!;
                    String diskon = "";
                    if (data == "Biasa") {
                      diskon = "0";
                    }
                    if (data == "Pelanggan") {
                      diskon = "2%";
                    }
                    if (data == "Pelanggan Istimewa") {
                      diskon = "4%";
                    }
                    _txtDiskon.text = diskon;
                  });
                }),
            SizedBox(
              height: marginBetween,
            ),
            CustomTextField(
              textInputType: TextInputType.phone,
              hintText: "Masukkan Jumlah Pembelian",
              labelText: "Jumlah Pembelian",
              controller: _txtJmlhPembelian,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(
              height: marginBetween,
            ),
            CustomTextField(
              textInputType: TextInputType.number,
              initValue: "0",
              hintText: "Masukkan Diskon",
              labelText: "Diskon",
              controller: _txtDiskon,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(
              height: marginBetween,
            ),
            Text("Hari Libur"),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<RadioCharacter>(
                    title: const Text('Ya'),
                    value: RadioCharacter.y,
                    groupValue: hariLibur,
                    onChanged: (RadioCharacter? value) {
                      setState(() {
                        hariLibur = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<RadioCharacter>(
                    title: const Text('Tidak'),
                    value: RadioCharacter.n,
                    groupValue: hariLibur,
                    onChanged: (RadioCharacter? value) {
                      setState(() {
                        hariLibur = value;
                      });
                    },
                  ),
                )
              ],
            ),
            SizedBox(
              height: marginBetween,
            ),
            Text("Saudara"),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<RadioCharacter>(
                    title: const Text('Ya'),
                    value: RadioCharacter.y,
                    groupValue: saudara,
                    onChanged: (RadioCharacter? value) {
                      setState(() {
                        saudara = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<RadioCharacter>(
                    title: const Text('Tidak'),
                    value: RadioCharacter.n,
                    groupValue: saudara,
                    onChanged: (RadioCharacter? value) {
                      setState(() {
                        saudara = value;
                      });
                    },
                  ),
                )
              ],
            ),
            SizedBox(
              height: marginBetween,
            ),
            Text(
              "Jenis Barang",
            ),
            CheckboxGroup(
              orientation: GroupedButtonsOrientation.VERTICAL,
              margin: const EdgeInsets.only(left: 12.0),
              onSelected: (selected) => setState(() {
                jenisBrgValList = selected;
              }),
              labels: jenisBarangList,
              checked: jenisBrgValList,
              itemBuilder: (Checkbox cb, Text txt, int i) {
                return Row(
                  children: <Widget>[
                    cb,
                    txt,
                  ],
                );
              },
            ),
            SizedBox(
              height: marginBetween,
            ),
            CustomTextField(
              textInputType: TextInputType.number,
              hintText: "Masukkan PPN",
              labelText: "PPN",
              controller: _txtPpn,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(
              height: marginBetween,
            ),
            diskonAmt > 0
                ? Row(
                    children: [
                      Text(
                        "Diskon : ",
                        style: defaultFontStyle,
                      ),
                      Text(
                        diskonAmt.toString(),
                        style: defaultFontStyle,
                      )
                    ],
                  )
                : Column(),
            SizedBox(
              height: marginBetween,
            ),
            Row(
              children: [
                Text(
                  "PPN : ",
                  style: defaultFontStyle,
                ),
                Text(
                  taxAmt.toString(),
                  style: defaultFontStyle,
                )
              ],
            ),
            SizedBox(
              height: marginBetween,
            ),
            Row(
              children: [
                Text(
                  "Grandtotal : ",
                  style: defaultFontStyle,
                ),
                Text(
                  grandtotal.toString(),
                  style: defaultFontStyle,
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            CustomTextField(
              textInputType: TextInputType.phone,
              hintText: "Masukkan Pembayaran",
              labelText: "Pembayaran",
              controller: _txtKembalian,
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Text(
                  "Uang Kembali : ",
                  style: defaultFontStyle,
                ),
                Text(
                  kembalian.toString(),
                  style: defaultFontStyle,
                )
              ],
            ),
            SizedBox(
              height: marginBetween,
            ),
            Text("Foto"),
            foto()
          ],
        ),
      );
    }

    Widget view() {
      double c_width = MediaQuery.of(context).size.width * 0.9;
      return Container(
        padding: EdgeInsets.only(top: 16),
        width: c_width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [],
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Form Penjualan"),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [formInput(), buttonProses(), view()],
          ),
        ),
      ),
    );
  }
}
