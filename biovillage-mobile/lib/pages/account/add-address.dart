import 'package:biovillage/widgets/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/account.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/helpers/net-connection.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/form-elements.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/map.dart';

class AddAddressPageArguments {
  AddAddressPageArguments({
    @required this.coords,
    @required this.address,
    @required this.deliveryPrice,
    @required this.deliveryFreeSum,
    this.city,
    this.onAddressAdded,
  });

  final Point coords;
  final String address;
  final int deliveryPrice;
  final int deliveryFreeSum;
  final String city;
  final Function onAddressAdded;
}

class AddAddressPage extends StatefulWidget {
  AddAddressPage({Key key}) : super(key: key);
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  GlobalKey<AutoCompleteTextFieldState<String>> adrNameFieldKey = new GlobalKey();
  AddAddressPageArguments _args;
  TextEditingController _addressName = TextEditingController();
  TextEditingController _addressText = TextEditingController();
  TextEditingController _appt = TextEditingController();
  TextEditingController _entrance = TextEditingController();
  TextEditingController _doorphone = TextEditingController();
  TextEditingController _floor = TextEditingController();
  TextEditingController _comment = TextEditingController();
  String _addressNameError;
  bool _loading = false;

  // Сохранение адреса:
  void saveAddress() async {
    // Валидация:
    if (_addressName.text.isEmpty) {
      setState(() => _addressNameError = FlutterI18n.translate(context, 'common.account.enter_address_name'));
      showToast(FlutterI18n.translate(context, 'common.form_has_errors'), isError: true);
      return;
    }
    // Сохранение:
    setState(() => _loading = true);
    var store = StoreProvider.of<AppState>(context);
    bool failed = false;
    await store.dispatch(addAddress(
      Address(
        name: _addressName.text,
        coords: _args.coords,
        address: _args.address,
        city: _args.city,
        appt: _appt.text,
        entrance: _entrance.text,
        doorphone: _doorphone.text,
        floor: _floor.text,
        comment: _comment.text,
        deliveryPrice: _args.deliveryPrice,
        deliveryFreeSum: _args.deliveryFreeSum,
      ),
      onFailed: (errors) {
        // Если ошибки не пришли, то проверим подключение к нету:
        if (errors == null) checkConnect(context);
        setState(() => _loading = false);
        failed = true;
      },
    ));
    if (failed) return;
    Navigator.pop(context);
    Navigator.pop(context);
    setState(() => _loading = false);
    if (_args.onAddressAdded != null) _args.onAddressAdded();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _args = ModalRoute.of(context).settings.arguments;
      _addressText.text = _args.address;
    });
    _addressName.addListener(() {
      setState(() => _addressNameError = null);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _addressName.dispose();
    _addressText.dispose();
    _appt.dispose();
    _entrance.dispose();
    _doorphone.dispose();
    _floor.dispose();
    _comment.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _addrSuggestions =
        FlutterI18n.translate(context, 'common.account.address_suggestions').split('|');

    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.account.add_address')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: AutoCompleteTextField(
                        key: adrNameFieldKey,
                        controller: _addressName,
                        clearOnSubmit: false,
                        suggestions: _addrSuggestions,
                        minLength: 0,
                        itemSorter: (a, b) => _addrSuggestions.indexOf(a).compareTo(_addrSuggestions.indexOf(b)),
                        itemFilter: (suggestion, input) => input.length > 0 ? false : true,
                        itemSubmitted: (item) => setState(() => _addressName.text = item),
                        textSubmitted: (data) {},
                        itemBuilder: (context, suggestion) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(suggestion),
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          hintText: '* ' + FlutterI18n.translate(context, 'common.account.address_name'),
                          hintStyle: TextStyle(
                            fontSize: 13.w,
                            fontWeight: FontWeight.w400,
                            color: ColorsTheme.textTertiary,
                          ),
                          filled: true,
                          fillColor: ColorsTheme.textFieldBg,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          errorText: _addressNameError,
                          errorStyle: TextStyle(fontSize: 11.w, height: 1, color: ColorsTheme.error),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ColorsTheme.error),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ColorsTheme.error),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13.w,
                          color: ColorsTheme.textMain,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(height: 4, color: darken(ColorsTheme.bg, .02)),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextFormField(
                            controller: _addressText,
                            hintText: '* ' + FlutterI18n.translate(context, 'common.address'),
                            enabled: false,
                          ),
                          SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _appt,
                            keyboardType: TextInputType.number,
                            hintText: FlutterI18n.translate(context, 'common.account.appt'),
                          ),
                          SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _entrance,
                            keyboardType: TextInputType.number,
                            hintText: FlutterI18n.translate(context, 'common.account.entrance'),
                          ),
                          SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _doorphone,
                            hintText: FlutterI18n.translate(context, 'common.account.doorphone'),
                          ),
                          SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _floor,
                            keyboardType: TextInputType.number,
                            hintText: FlutterI18n.translate(context, 'common.account.floor'),
                          ),
                          SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _comment,
                            keyboardType: TextInputType.multiline,
                            hintText: FlutterI18n.translate(context, 'common.comment'),
                            maxLines: 10,
                          ),
                          SizedBox(height: 24),
                          Text(
                            '* - ' + FlutterI18n.translate(context, 'common.required_fields').toLowerCase(),
                            style: TextStyle(fontSize: 12.w, color: ColorsTheme.textTertiary),
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: darken(ColorsTheme.bg, .02), width: 4))),
              padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
              child: Button(
                label: FlutterI18n.translate(context, 'common.save'),
                loading: _loading,
                onTap: () => saveAddress(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
